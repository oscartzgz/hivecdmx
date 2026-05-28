require "application_system_test_case"

class RecordsTest < ApplicationSystemTestCase
  ROOM     = "101"
  CATEGORY = "Puerta habitacion"
  ITEM     = "Marco"

  setup do
    @user = create_inspector
    sign_in_as(@user)
    visit room_url(ROOM, category: CATEGORY)
  end

  # ── Contadores de métricas ──────────────────────────────────────────────────

  test "el contador de pendientes muestra todos los ítems cuando no hay registros guardados" do
    total = Checklist.categories.sum { |c| c["items"].length }
    visit room_url(ROOM)

    within find("[data-metric='pendientes']") do
      assert_text total.to_s
    end
  end

  test "completar un ítem reduce el contador de pendientes en uno" do
    total = Checklist.categories.sum { |c| c["items"].length }
    visit room_url(ROOM, category: CATEGORY)

    within_item_card(ITEM) do
      click_button "Completado"
      assert_selector ".status-pill--completado"
    end

    visit room_url(ROOM)
    within find("[data-metric='pendientes']") do
      assert_text (total - 1).to_s
    end
  end

  # ── Estado por defecto (pendiente) ──────────────────────────────────────────

  test "estado pendiente se muestra como activo y visualmente distinto de los botones inactivos" do
    within_item_card(ITEM) do
      # El botón pendiente debe tener is-active (estado por defecto)
      active_btn   = find("button.segmented__btn.is-active[value='pendiente']")
      inactive_btn = find("button.segmented__btn[value='completado']")

      # El fondo del botón pendiente activo debe ser DISTINTO al de un botón inactivo.
      # Con el bug actual ambos son rgb(245, 245, 244) (gris neutro).
      active_bg   = page.evaluate_script("window.getComputedStyle(arguments[0]).backgroundColor", active_btn)
      inactive_bg = page.evaluate_script("window.getComputedStyle(arguments[0]).backgroundColor", inactive_btn)

      assert active_bg != inactive_bg,
        "El botón pendiente activo (#{active_bg}) debe tener fondo distinto al botón completado inactivo (#{inactive_bg})"
    end
  end

  test "la píldora del estado pendiente tiene color de texto distinto al color base muted" do
    within_item_card(ITEM) do
      pill = find(".status-pill--pendiente")
      pill_color = page.evaluate_script("window.getComputedStyle(arguments[0]).color", pill)

      # rgb(120, 113, 108) es --color-text-muted (gris), que hace que la píldora
      # parezca deshabilitada. Con el fix debe ser ámbar (#92400e → rgb(146, 64, 14)).
      assert pill_color != "rgb(120, 113, 108)",
        "La píldora pendiente no debe usar el mismo color gris que --color-text-muted (#{pill_color})"
    end
  end

  # ── Actualización en vivo de métricas ──────────────────────────────────────

  test "los contadores de métricas se actualizan en vivo al completar un ítem" do
    total = Checklist.categories.sum { |c| c["items"].length }

    within_item_card(ITEM) do
      click_button "Completado"
      assert_selector ".status-pill--completado"
    end

    # Sin recargar la página: los contadores deben reflejar el nuevo estado
    within find("[data-metric='completados']") do
      assert_text "1"
    end
    within find("[data-metric='pendientes']") do
      assert_text (total - 1).to_s
    end
  end

  test "los contadores de métricas se actualizan en vivo al marcar como defectuoso" do
    total = Checklist.categories.sum { |c| c["items"].length }

    within_item_card(ITEM) do
      click_button "Defectuoso"
      assert_selector ".status-pill--defectuoso"
    end

    within find("[data-metric='defectuosos']") do
      assert_text "1"
    end
    within find("[data-metric='pendientes']") do
      assert_text (total - 1).to_s
    end
  end

  # ── Cambio de estado ────────────────────────────────────────────────────────

  test "marcar como completado actualiza la píldora de estado" do
    within_item_card(ITEM) do
      click_button "Completado"
      assert_selector ".status-pill--completado", text: "completado"
    end
  end

  test "marcar como defectuoso actualiza la píldora de estado" do
    within_item_card(ITEM) do
      click_button "Defectuoso"
      assert_selector ".status-pill--defectuoso", text: "defectuoso"
    end
  end

  test "marcar como pendiente desde otro estado vuelve a pendiente" do
    # Primero completar
    within_item_card(ITEM) { click_button "Completado" }
    within_item_card(ITEM) { assert_selector ".status-pill--completado" }
    # Luego regresar a pendiente
    within_item_card(ITEM) do
      click_button "Pendiente"
      assert_selector ".status-pill--pendiente", text: "pendiente"
    end
  end

  # ── Persistencia ────────────────────────────────────────────────────────────

  test "el estado persiste al recargar la página" do
    within_item_card(ITEM) { click_button "Completado" }
    within_item_card(ITEM) { assert_selector ".status-pill--completado" }

    visit room_url(ROOM, category: CATEGORY)

    within_item_card(ITEM) do
      assert_selector ".status-pill--completado"
      assert_selector "button.is-active[value='completado']"
    end
  end

  # ── Historial / Comentarios ──────────────────────────────────────────────────

  test "el historial se abre automáticamente al cambiar el estado" do
    within_item_card(ITEM) do
      click_button "Defectuoso"
      assert_selector ".status-pill--defectuoso"
      # El <details> debe estar abierto y mostrar la entrada automática
      assert_selector "details[open] .comment .status-pill--defectuoso"
    end
  end

  test "guardar un seguimiento manual lo muestra en el historial" do
    # Primero crear el record cambiando el estado
    within_item_card(ITEM) do
      click_button "Completado"
      assert_selector ".status-pill--completado"
    end

    # Luego agregar un comentario manual
    within_item_card(ITEM) do
      fill_in placeholder: "Agregar seguimiento, observación o nota de avance...", with: "Pintura dañada"
      click_button "Guardar seguimiento"
      # El historial debe mostrar el comentario manual
      assert_selector "details[open] .comment .comment__body", text: "Pintura dañada"
    end
  end

  test "el div de historial tiene el id correcto para el turbo stream" do
    expected_id = "record-#{ROOM}-#{ITEM.parameterize}-history"

    within_item_card(ITEM) do
      click_button "Completado"
      assert_selector ".status-pill--completado"
      assert_selector "[id='#{expected_id}']", visible: :all
    end
  end

  # ── Avance ──────────────────────────────────────────────────────────────────

  test "el porcentaje de avance aumenta al completar un item" do
    visit room_url(ROOM)
    initial_pct = find(".topbar__metric-value").text.to_i

    click_link CATEGORY
    within_item_card(ITEM) do
      click_button "Completado"
      assert_selector ".status-pill--completado"
    end

    visit room_url(ROOM)
    new_pct = find(".topbar__metric-value").text.to_i
    assert new_pct > initial_pct, "El % de avance debería haber subido (era #{initial_pct}%, ahora #{new_pct}%)"
  end

  private

  def within_item_card(item_name, &)
    card = find("article.item-card", text: item_name)
    within(card, &)
  end
end
