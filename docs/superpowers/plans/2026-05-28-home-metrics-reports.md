# Home Metrics + Reports Access — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Añadir métricas globales y progreso por habitación en la home, y proteger los reportes como admin-only con un acceso visible desde la home.

**Architecture:** Tres cambios independientes que se integran: (1) mover `require_admin` a `ApplicationController` y guardarlo en `ReportsController`, (2) calcular métricas en `RoomsController#index` con 2 queries, (3) reescribir `rooms/index.html.slim` con el nuevo layout + CSS.

**Tech Stack:** Rails 8.1 · Slim · PostgreSQL · Minitest + Capybara

---

## Archivos a modificar

| Archivo | Cambio |
|---|---|
| `app/controllers/application_controller.rb` | Añadir `require_admin` privado |
| `app/controllers/admin/base_controller.rb` | Eliminar `require_admin` local (hereda de Application) |
| `app/controllers/reports_controller.rb` | `before_action :require_admin` |
| `app/views/reports/show.html.slim` | Cambiar `export_reports_path` → `export_report_path` |
| `config/routes.rb` | `resource :reports` (singular) |
| `app/controllers/rooms_controller.rb` | Cargar `@room_stats` y métricas globales en `#index` |
| `app/views/rooms/index.html.slim` | Topbar %, métricas globales, grid con barras, sección admin |
| `app/assets/stylesheets/application.css` | Estilos para `.btn--room`, `.room-progress`, `.admin-section`, `.btn--dark` |
| `test/controllers/reports_controller_test.rb` | Tests de acceso (inspector redirigido, admin permitido) |
| `test/controllers/rooms_controller_test.rb` | Test que verifica que index responde con éxito |
| `test/system/rooms_test.rb` | Tests de sistema para métricas, admin section, navegación a reportes |

---

## Task 1: Reports access control + route fix

**Files:**
- Modify: `app/controllers/application_controller.rb`
- Modify: `app/controllers/admin/base_controller.rb`
- Modify: `app/controllers/reports_controller.rb`
- Modify: `app/views/reports/show.html.slim`
- Modify: `config/routes.rb`
- Create: `test/controllers/reports_controller_test.rb`

- [ ] **Step 1: Escribir los tests de acceso a reportes**

Crear `test/controllers/reports_controller_test.rb`:

```ruby
require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @inspector = users(:inspector_one)
    @admin     = users(:admin_one)
  end

  test "inspector is redirected from reports" do
    post session_url, params: { session: { email_address: @inspector.email_address, password: "password123" } }
    get report_url
    assert_redirected_to root_path
    assert_equal "Acceso restringido.", flash[:alert]
  end

  test "admin can access reports" do
    post session_url, params: { session: { email_address: @admin.email_address, password: "password123" } }
    get report_url
    assert_response :success
  end
end
```

- [ ] **Step 2: Ejecutar los tests para verificar que fallan**

```bash
docker exec hive-rails-web-1 bin/rails test test/controllers/reports_controller_test.rb
```

Esperado: 2 errores — `report_url` no existe aún.

- [ ] **Step 3: Corregir rutas a `resource :reports` (singular)**

En `config/routes.rb`, cambiar:

```ruby
resources :reports, only: [ :show ] do
  collection { get :export }
end
```

por:

```ruby
resource :reports, only: [ :show ] do
  get :export, on: :member
end
```

- [ ] **Step 4: Actualizar el helper de export en la vista de reporte**

En `app/views/reports/show.html.slim`, línea 48, cambiar:

```slim
= link_to "CSV", export_reports_path(room: @room, date: @date), class: "btn btn--outline"
```

por:

```slim
= link_to "CSV", export_report_path(room: @room, date: @date), class: "btn btn--outline"
```

- [ ] **Step 5: Mover `require_admin` a ApplicationController**

En `app/controllers/application_controller.rb`:

```ruby
class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  def require_admin
    redirect_to root_path, alert: "Acceso restringido." unless Current.user&.admin?
  end
end
```

- [ ] **Step 6: Eliminar `require_admin` de Admin::BaseController**

En `app/controllers/admin/base_controller.rb`:

```ruby
module Admin
  class BaseController < ApplicationController
    before_action :require_admin
  end
end
```

(El método `require_admin` ahora hereda de `ApplicationController`.)

- [ ] **Step 7: Proteger ReportsController**

En `app/controllers/reports_controller.rb`, añadir `before_action :require_admin` como primera línea del cuerpo de la clase:

```ruby
class ReportsController < ApplicationController
  before_action :require_admin

  def show
    # ... resto igual
  end

  def export
    # ... resto igual
  end
end
```

- [ ] **Step 8: Ejecutar los tests para verificar que pasan**

```bash
docker exec hive-rails-web-1 bin/rails test test/controllers/reports_controller_test.rb
```

Esperado: 2 runs, 0 failures, 0 errors.

- [ ] **Step 9: Ejecutar suite completa para verificar no hay regresiones**

```bash
docker exec hive-rails-web-1 bin/rails test
```

Esperado: 0 failures, 0 errors.

- [ ] **Step 10: Commit**

```bash
git add app/controllers/application_controller.rb \
        app/controllers/admin/base_controller.rb \
        app/controllers/reports_controller.rb \
        app/views/reports/show.html.slim \
        config/routes.rb \
        test/controllers/reports_controller_test.rb
git commit -m "feat: protect reports with require_admin, fix to singular resource route"
```

---

## Task 2: RoomsController#index — cargar métricas

**Files:**
- Modify: `app/controllers/rooms_controller.rb`

- [ ] **Step 1: Verificar que la suite actual pasa antes de tocar nada**

```bash
docker exec hive-rails-web-1 bin/rails test
```

Esperado: 0 failures, 0 errors.

- [ ] **Step 2: Actualizar RoomsController#index**

En `app/controllers/rooms_controller.rb`, reemplazar el método `index` completo:

```ruby
def index
  @rooms      = Checklist.rooms
  total_items = Checklist.categories.sum { |c| c["items"].length }

  raw         = Record.group(:room, :status).count
  all_records = Record.group(:status).count

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

El método `show` no cambia.

- [ ] **Step 3: Ejecutar la suite para verificar no hay regresiones**

```bash
docker exec hive-rails-web-1 bin/rails test
```

Esperado: 0 failures, 0 errors.

- [ ] **Step 4: Commit del controlador**

```bash
git add app/controllers/rooms_controller.rb
git commit -m "feat: load global metrics and per-room stats in rooms#index"
```

---

## Task 3: Vista home + CSS

**Files:**
- Modify: `app/views/rooms/index.html.slim`
- Modify: `app/assets/stylesheets/application.css`
- Modify: `test/system/rooms_test.rb`

- [ ] **Step 1: Escribir los tests (integración + sistema)**

En `test/controllers/rooms_controller_test.rb`, añadir al final de la clase `RoomsControllerTest` (antes del cierre `end`):

```ruby
test "index shows global metric cards" do
  get rooms_url
  assert_response :success
  assert_select "[data-metric='completados']"
  assert_select "[data-metric='pendientes']"
  assert_select "[data-metric='defectuosos']"
end
```

En `test/system/rooms_test.rb`, añadir una nueva clase al final del archivo (después de la clase `RecordsTest`):

```ruby
class HomeTest < ApplicationSystemTestCase
  setup do
    @inspector = create_inspector
    @admin     = create_admin
  end

  test "la home muestra las 3 tarjetas de métricas globales" do
    sign_in_as(@inspector)
    visit rooms_url
    assert_selector "[data-metric='completados']"
    assert_selector "[data-metric='pendientes']"
    assert_selector "[data-metric='defectuosos']"
  end

  test "inspector no ve la sección de administración" do
    sign_in_as(@inspector)
    visit rooms_url
    assert_no_selector ".admin-section"
  end

  test "admin ve la sección de administración con links a reportes y usuarios" do
    sign_in_as(@admin)
    visit rooms_url
    assert_selector ".admin-section"
    assert_selector ".admin-section a", text: /Reportes/i
    assert_selector ".admin-section a", text: /Usuarios/i
  end

  test "admin puede navegar a reportes desde la home" do
    sign_in_as(@admin)
    visit rooms_url
    within(".admin-section") { click_on "Reportes" }
    assert_current_path report_path, wait: 5
  end
end
```

- [ ] **Step 2: Ejecutar los tests para verificar que fallan**

```bash
docker exec hive-rails-web-1 bin/rails test test/controllers/rooms_controller_test.rb
docker exec hive-rails-web-1 bin/rails test:system TEST=test/system/rooms_test.rb
```

Esperado: el test de integración de métricas falla (`[data-metric]` no existe en la vista), y los 4 tests de sistema fallan (`.admin-section`, métricas no están).

- [ ] **Step 3: Reescribir app/views/rooms/index.html.slim**

```slim
/ app/views/rooms/index.html.slim
header.topbar
  div
    p.topbar__eyebrow Hive Centro Histórico
    h1.topbar__title Seleccionar habitación
  div.topbar__metric
    span.topbar__metric-value = "#{@global_pct}%"
    span.topbar__metric-label avance

section.metrics
  div.metrics
    div.metric-card.metric-card--complete data-metric="completados"
      span.metric-card__value = @global_completed
      span.metric-card__label completados
    div.metric-card.metric-card--pending data-metric="pendientes"
      span.metric-card__value = @global_pending
      span.metric-card__label pendientes
    div.metric-card.metric-card--defective data-metric="defectuosos"
      span.metric-card__value = @global_defective
      span.metric-card__label defectuosos

div.container style="padding:var(--space-2) var(--space-4) var(--space-4)"
  div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(72px,1fr));gap:var(--space-2)"
    - @rooms.each do |room|
      - stats        = @room_stats[room]
      - pct          = stats[:total] > 0 ? (stats[:completed] * 100 / stats[:total]) : 0
      - border_class = if stats[:defective] > 0 then "btn--room-defective" elsif stats[:completed] > 0 then "btn--room-progress" else "" end
      = link_to room_path(room), class: "btn btn--outline btn--room #{border_class}" do
        = room
        div.room-progress
          div.room-progress__bar style="width:#{pct}%"

  - if Current.user.admin?
    div.admin-section
      p.admin-section__label Administración
      div style="display:grid;grid-template-columns:1fr 1fr;gap:var(--space-2)"
        = link_to report_path, class: "btn btn--dark"
          | 📊 Reportes
        = link_to admin_users_path, class: "btn btn--outline"
          | 👥 Usuarios
```

- [ ] **Step 4: Añadir estilos en application.css**

Al final de `app/assets/stylesheets/application.css`, antes del último comentario o al final del archivo, añadir:

```css
/* ── Room buttons con barra de progreso ── */

.btn--room {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: var(--space-1);
  padding: var(--space-2) var(--space-1);
  text-align: center;
}

.btn--room-progress  { border-color: var(--color-complete-border); }
.btn--room-defective { border-color: var(--color-defective-border); }

.room-progress {
  width: 100%;
  height: 3px;
  background: var(--color-border);
  border-radius: 2px;
  overflow: hidden;
}

.room-progress__bar {
  height: 100%;
  border-radius: 2px;
  background: var(--color-complete-border);
}

.btn--room-defective .room-progress__bar { background: var(--color-defective-border); }

/* ── Sección Administración (solo admins) ── */

.admin-section {
  margin-top: var(--space-4);
  border-top: 1px solid var(--color-border);
  padding-top: var(--space-3);
}

.admin-section__label {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-bold);
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin: 0 0 var(--space-2);
}

/* ── Botón oscuro ── */

.btn--dark {
  background: var(--color-text);
  color: #fff;
  border-color: transparent;
}

.btn--dark:hover { opacity: 0.85; }

/* ── Metric card pendientes ── */

.metric-card--pending { border-color: var(--color-pending-border); }
.metric-card--pending .metric-card__value { color: var(--color-pending); }
```

- [ ] **Step 5: Ejecutar los tests de sistema**

```bash
docker exec hive-rails-web-1 bin/rails test:system TEST=test/system/rooms_test.rb
```

Esperado: 4 runs, 0 failures, 0 errors.

- [ ] **Step 6: Ejecutar toda la suite (integración + sistema)**

```bash
docker exec hive-rails-web-1 bin/rails test && docker exec hive-rails-web-1 bin/rails test:system
```

Esperado: 0 failures, 0 errors en ambas suites.

- [ ] **Step 7: Commit final**

```bash
git add app/views/rooms/index.html.slim \
        app/assets/stylesheets/application.css \
        test/controllers/rooms_controller_test.rb \
        test/system/rooms_test.rb
git commit -m "feat: home metrics, per-room progress bars, admin section with reports link"
```
