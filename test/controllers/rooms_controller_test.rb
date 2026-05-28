# test/controllers/rooms_controller_test.rb
require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:inspector_one)
    post session_url, params: { session: { email_address: @user.email_address, password: "password123" } }
  end

  test "show renders checklist for room" do
    get room_url("101")
    assert_response :success
    assert_select "article.item-card"
  end

  test "show defaults to first category" do
    get room_url("101")
    assert_response :success
    assert_select ".tab--active", text: "Puerta habitacion"
  end

  test "completed items appear after pending" do
    Record.create!(
      id: "101::Puerta habitacion::Marco",
      room: "101", category: "Puerta habitacion", item: "Marco",
      status: :completado, report_date: Date.today
    )
    get room_url("101")
    assert_response :success
    assert_select "[data-status='completado']"
  end

  test "index shows room list" do
    get rooms_url
    assert_response :success
    assert_select "a", text: "101"
  end

  test "redirects to login when not authenticated" do
    delete session_url
    get room_url("101")
    assert_redirected_to new_session_url
  end

  test "index shows room metric cards" do
    get rooms_url
    assert_response :success
    assert_select "[data-metric='completados']"
    assert_select "[data-metric='pendientes']"
  end
end
