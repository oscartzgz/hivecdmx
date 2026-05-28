# CLAUDE.md — Instrucciones para agentes de IA

Guía de desarrollo para este proyecto Rails. Lee esto completo antes de tocar código.

---

## Stack

- **Rails 8.1** · Ruby 3.4 · PostgreSQL 16
- **Hotwire**: Turbo Drive + Turbo Frames + Turbo Streams
- **Vistas**: Slim (nunca ERB)
- **Tests**: Minitest + Capybara + Selenium (Chrome headless)
- **Entorno local**: Docker Compose (`docker-compose.yml`)

---

## Convenciones de código

Seguimos las convenciones DHH/37signals:

- **Modelos gordos, controladores delgados**: lógica en el modelo.
- **Solo rutas REST**: `index`, `show`, `new`, `create`, `edit`, `update`, `destroy`. Nada fuera de CRUD.
- **Sin service objects**, sin form objects, sin presenters.
- **Minitest**: no RSpec. Fixtures (no factories).
- **Import maps**: no Webpack, no Node.

---

## Cómo correr el entorno

```bash
# Levantar contenedores (DB + servidor Rails en puerto 4000)
docker compose up

# Correr todos los tests (integration + system) dentro del contenedor
docker exec hive-rails-web-1 bin/rails test
docker exec hive-rails-web-1 bin/rails test:system

# Solo tests de sistema
docker exec hive-rails-web-1 bin/rails test:system

# Un archivo concreto
docker exec hive-rails-web-1 bin/rails test test/system/records_test.rb
```

---

## Regla de oro de tests: TODA modificación lleva test de sistema

> **Si cambias comportamiento visible en el navegador — vistas, controladores, JS —
> debes incluir o actualizar el test de sistema correspondiente.**

Esto NO es opcional. Un cambio sin su test de sistema será rechazado.

### Cuándo escribir test de sistema (browser/Capybara) vs. test de integración (HTTP puro)

| Tipo de cambio | Test requerido |
|---|---|
| Vista Slim nueva o modificada | **Sistema** |
| Flujo Turbo Stream / Turbo Frame | **Sistema** (es el único que ejercita el JS) |
| Validación que afecta la UI | **Sistema** |
| Lógica de controlador (redireccionamientos, filtros) | Integración + Sistema |
| Modelo puro (validaciones, scopes, métodos) | Unitario/integración |
| Ruta o acción nueva | Integración + **Sistema** |
| Cambio de autorización (quién puede ver qué) | **Sistema** (verifica el redirect real) |

### Dónde viven los tests de sistema

```
test/
  application_system_test_case.rb   ← base: Chrome, helpers, limpieza de DB
  system/
    sessions_test.rb                ← login / logout / rutas protegidas
    rooms_test.rb                   ← index de habitaciones, navegación, tabs
    records_test.rb                 ← actualizar estado de partidas (Turbo Streams)
    admin/
      users_test.rb                 ← CRUD de usuarios, control de acceso
```

### Cómo estructurar un test de sistema nuevo

```ruby
require "application_system_test_case"

class MiFeatureTest < ApplicationSystemTestCase
  setup do
    @user = create_inspector   # o create_admin
    sign_in_as(@user)
  end

  test "describe el comportamiento exacto que verifica" do
    visit alguna_url
    click_on "Algo"
    assert_text "Resultado esperado"
  end
end
```

**Helpers disponibles en `ApplicationSystemTestCase`:**

| Helper | Descripción |
|---|---|
| `create_inspector(email:, name:, password:)` | Crea usuario inspector en la DB |
| `create_admin(email:, name:, password:)` | Crea usuario admin en la DB |
| `sign_in_as(user, password:)` | Login via formulario + espera redirección |

La DB se trunca automáticamente antes y después de cada test (`setup`/`teardown`).

---

## Advertencias técnicas importantes (aprendidas a base de bugs)

### 1. `form_with` siempre con `scope:`

Cuando el formulario maneja un recurso pero no se pasa un modelo ActiveRecord,
declara `scope: :nombre_del_recurso` explícitamente:

```slim
/ ✅ Correcto
= form_with url: record_path(id), method: :patch, scope: :record do |f|
  = f.hidden_field :room, value: room

/ ❌ Incorrecto — los campos hidden llegan sin namespace en params
= form_with url: record_path(id), method: :patch do |f|
  = f.hidden_field :room, value: room
```

Sin `scope:`, `params.require(:record).permit(:room)` devuelve `nil` porque
`room` llega a nivel raíz en lugar de `params[:record][:room]`.

### 2. Turbo Drive + Capybara necesita esperar la navegación

Después de un `click_on` que dispara un submit Turbo, la redirección es
asíncrona. Usa una aserción con espera en lugar de comprobar `current_path`
inmediatamente:

```ruby
# ✅ Espera activa a que Turbo complete la navegación
click_on "Entrar"
assert_no_current_path new_session_path, wait: 5

# ❌ Puede leer la URL antes de que Turbo actualice
click_on "Entrar"
assert_current_path rooms_path   # puede fallar en race condition
```

### 3. Chrome en Docker requiere flags de seguridad

En el contenedor Docker no hay sandbox de sistema operativo; Chrome necesita:

```ruby
driven_by :selenium, using: :headless_chrome do |opts|
  opts.add_argument("--no-sandbox")
  opts.add_argument("--disable-dev-shm-usage")
  opts.add_argument("--disable-gpu")
end
```

### 4. `use_transactional_tests = false` en tests de sistema

Los tests de sistema usan un servidor Puma en un hilo separado. Con la
configuración por defecto (`lock_threads = true`, transacciones), el hilo de
Puma no puede ver los fixtures del hilo del test → el login falla.

La solución adoptada en este proyecto:
- `use_transactional_tests = false` en `ApplicationSystemTestCase`
- Los datos se crean con `create_inspector`/`create_admin` en cada `setup`
- Se truncan con `TRUNCATE ... CASCADE` antes y después de cada test

No uses `fixtures :all` directamente en tests de sistema.

---

## Checklist antes de hacer commit

- [ ] `bin/rails test` pasa (0 fallos, 0 errores)
- [ ] `bin/rails test:system` pasa (0 fallos, 0 errores)
- [ ] Si el cambio afecta la UI: hay un test de sistema nuevo o actualizado
- [ ] Las vistas están en Slim, no en ERB
- [ ] No hay lógica de negocio en controladores ni vistas
