# Home: métricas globales + progreso por habitación + acceso a reportes

**Fecha:** 2026-05-28  
**Estado:** aprobado

---

## Resumen

Dos cambios relacionados:

1. **Home (`rooms#index`)** — añadir métricas globales del proyecto y una mini barra de progreso en cada botón de habitación, más una sección "Administración" visible solo para admins.
2. **Reportes** — ya existen pero no tienen link de navegación ni control de acceso. Se protegen con `require_admin` y se exponen desde la sección admin de la home.

---

## Home — diseño visual aprobado

### Topbar
- Lado izquierdo: texto existente ("Hive Centro Histórico" + "Seleccionar habitación").
- Lado derecho: badge compacto con el **% de avance global** (completados / total ítems de todas las habitaciones × 100).

### Métricas globales (3 tarjetas)
Debajo del topbar, una fila de 3 `metric-card` con conteos **de todas las habitaciones juntas**:
- **Completados** — borde verde (`--color-complete-border`)
- **Pendientes** — borde ámbar (`--color-pending-border`)
- **Defectuosos** — borde rojo (`--color-defective-border`)

Total de ítems = suma de todos los ítems del checklist × número de habitaciones. Los conteos se obtienen de los `Record` existentes; los ítems sin Record cuentan como pendientes.

### Grid de habitaciones
Cada botón muestra el número de habitación y una mini barra de progreso de 3 px:
- Barra verde (`--color-complete-border`) si completados > 0 y defectuosos = 0.
- Barra roja (`--color-defective-border`) si defectuosos > 0 (independientemente de completados).
- Sin barra (solo fondo gris) si no hay ningún Record para esa habitación.

El borde del botón sigue el mismo color que la barra.

### Sección "Administración" (solo admins)
Separada del grid por un `border-top`, visible únicamente cuando `Current.user.admin?`:
- Label "Administración" en uppercase pequeño.
- Dos botones en grid 2 columnas: **📊 Reportes** → `report_path` · **👥 Usuarios** → `admin_users_path`.

---

## Reportes — control de acceso

`ReportsController` actualmente no tiene ninguna restricción de acceso.

### Cambios
- Mover el método `require_admin` de `Admin::BaseController` a `ApplicationController` para que sea accesible desde cualquier controlador.
- `Admin::BaseController` sigue usando `before_action :require_admin` (ya lo tiene).
- `ReportsController` añade `before_action :require_admin`.
- La ruta actual es `resources :reports, only: [:show]` que genera `GET /reports/:id`. El controlador ignora `:id` y usa `params[:room]`. Corregir a `resource :reports, only: [:show]` (singular, sin id) para que `GET /reports` funcione. El export pasa de `collection { get :export }` a `get :export, on: :member` → `GET /reports/export`. El helper cambia a `report_path` (sin argumento).

---

## Datos — `RoomsController#index`

```ruby
def index
  @rooms      = Checklist.rooms
  total_items = Checklist.categories.sum { |c| c["items"].length }

  # 2 queries en total
  raw         = Record.group(:room, :status).count          # { ["101","completado"] => 5, … }
  all_records = Record.group(:status).count                 # { "completado" => 428, … }

  @room_stats = @rooms.index_with do |room|
    { completed: raw[[room, "completado"]] || 0,
      defective: raw[[room, "defectuoso"]]  || 0,
      total:     total_items }
  end

  @global_completed = all_records["completado"] || 0
  @global_defective = all_records["defectuoso"]  || 0
  @global_pending   = (@rooms.length * total_items) - @global_completed - @global_defective
  @global_pct       = (@rooms.length * total_items) > 0 ?
                        (@global_completed * 100 / (@rooms.length * total_items)) : 0
end
```

---

## Archivos a modificar

| Archivo | Cambio |
|---|---|
| `app/controllers/application_controller.rb` | Añadir `require_admin` privado |
| `app/controllers/admin/base_controller.rb` | Eliminar definición local de `require_admin` (hereda de App) |
| `app/controllers/reports_controller.rb` | `before_action :require_admin` |
| `app/controllers/rooms_controller.rb` | Cargar `@room_stats` y métricas globales en `#index` |
| `app/views/rooms/index.html.slim` | Topbar con %, métricas globales, grid con barras, sección admin |
| `config/routes.rb` | `resource :reports` (singular) |

---

## Tests requeridos

Por CLAUDE.md, cualquier cambio de vista o flujo nuevo requiere test de sistema.

- **`test/system/rooms_test.rb`** — añadir tests de:
  - La home muestra las 3 tarjetas de métricas.
  - Un admin ve la sección "Administración" con los links de Reportes y Usuarios.
  - Un inspector NO ve la sección "Administración".
  - El link "Reportes" lleva a la página de reportes.
- **`test/controllers/reports_controller_test.rb`** — verificar que un inspector recibe redirect con alerta al intentar acceder a `/reports`.

---

## Lo que NO cambia

- El diseño visual de la vista de habitación (`rooms#show`) no cambia.
- El contenido de los reportes no cambia — solo su accesibilidad.
- No se añade paginación ni filtros al grid de habitaciones.
