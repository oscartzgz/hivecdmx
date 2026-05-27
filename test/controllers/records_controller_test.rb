# test/controllers/records_controller_test.rb
require "test_helper"

class RecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { session: {
      email_address: users(:inspector_one).email_address,
      password: "password123"
    }}
  end

  test "creates record on first update" do
    assert_difference "Record.count", 1 do
      patch record_url("101::Puerta habitacion::Marco"),
            params: { record: { status: "completado", room: "101",
                                category: "Puerta habitacion", item: "Marco",
                                owner: "MIFE", report_date: Date.today } },
            as: :turbo_stream
    end
    assert_response :success
    assert Record.find("101::Puerta habitacion::Marco").completado?
  end

  test "updates existing record" do
    record = Record.create!(
      id: "101::Carpinteria::Escritorio",
      room: "101", category: "Carpinteria", item: "Escritorio",
      status: :pendiente, report_date: Date.today
    )
    patch record_url(record),
          params: { record: { status: "defectuoso", note: "Pija suelta",
                              room: "101", category: "Carpinteria", item: "Escritorio",
                              owner: "BAKAN", report_date: Date.today } },
          as: :turbo_stream
    assert_response :success
    assert record.reload.defectuoso?
    assert_equal "Pija suelta", record.reload.note
  end

  test "responds with turbo stream replacing the frame" do
    patch record_url("101::Puerta habitacion::Marco"),
          params: { record: { status: "completado", room: "101",
                              category: "Puerta habitacion", item: "Marco",
                              owner: "MIFE", report_date: Date.today } },
          as: :turbo_stream
    assert_turbo_stream action: "replace"
  end
end
