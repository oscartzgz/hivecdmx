require "application_system_test_case"

class RoomsTest < ApplicationSystemTestCase
  setup do
    @user = create_inspector
    sign_in_as(@user)
  end

  # ── Index ──────────────────────────────────────────────────────────────────

  test "index muestra botones con número de habitación" do
    visit rooms_url

    assert_text "Seleccionar habitación"
    assert_link "101"
    assert_link "201"
  end

  test "clic en habitación navega a su checklist" do
    visit rooms_url
    click_link "101"

    assert_current_path room_path("101")
    assert_text "Habitación"
    assert_text "101"
  end

  # ── Show — topbar / navegación ─────────────────────────────────────────────

  test "show tiene enlace para volver a la lista de habitaciones" do
    visit room_url("101")
    assert_link href: rooms_path
  end

  test "show no muestra el texto estático Conectado" do
    visit room_url("101")
    assert_no_text "Conectado"
  end

  # ── Show ───────────────────────────────────────────────────────────────────

  test "show muestra la primera categoría activa por defecto" do
    visit room_url("101")

    first_category = Checklist.categories.first["name"]
    assert_selector ".tab--active", text: first_category
  end

  test "show muestra las tabs de cada categoría" do
    visit room_url("101")

    Checklist.categories.each do |cat|
      assert_link cat["name"]
    end
  end

  test "clic en una tab muestra los items de esa categoría" do
    visit room_url("101")
    click_link "Carpinteria"

    assert_selector ".tab--active", text: "Carpinteria"
    assert_selector ".item-card", minimum: 1
    assert_text "Escritorio"
  end

  test "show muestra barra de búsqueda" do
    visit room_url("101")
    assert_selector "input[type='search']"
  end

  test "show muestra porcentaje de avance" do
    visit room_url("101")
    assert_text "%"
  end

  test "items sin record aparecen como pendiente" do
    visit room_url("101")

    within first(".item-card") do
      assert_selector ".status-pill--pendiente"
    end
  end
end

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
    assert_current_path reports_path, wait: 5
  end
end
