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

  test "updates existing record status" do
    record = Record.create!(
      id: "101::Carpinteria::Escritorio",
      room: "101", category: "Carpinteria", item: "Escritorio",
      status: :pendiente, report_date: Date.today
    )
    patch record_url(record),
          params: { record: { status: "defectuoso",
                              room: "101", category: "Carpinteria", item: "Escritorio",
                              owner: "BAKAN", report_date: Date.today } },
          as: :turbo_stream
    assert_response :success
    assert record.reload.defectuoso?
  end

  test "al crear por primera vez agrega entrada pendiente inicial y entrada del nuevo estado" do
    assert_difference "Comment.count", 2 do
      patch record_url("101::Puerta habitacion::Marco"),
            params: { record: { status: "completado", room: "101",
                                category: "Puerta habitacion", item: "Marco",
                                owner: "MIFE", report_date: Date.today } },
            as: :turbo_stream
    end
    comments = Comment.where(record_id: "101::Puerta habitacion::Marco").chronological
    assert comments.first.pendiente?,   "la primera entrada debe ser pendiente"
    assert comments.second.completado?, "la segunda entrada refleja el nuevo estado"
  end

  test "al crear con estado pendiente agrega solo la entrada inicial pendiente" do
    assert_difference "Comment.count", 1 do
      patch record_url("101::Puerta habitacion::Marco"),
            params: { record: { status: "pendiente", room: "101",
                                category: "Puerta habitacion", item: "Marco",
                                owner: "MIFE", report_date: Date.today } },
            as: :turbo_stream
    end
    assert Comment.last.pendiente?
  end

  test "en un record existente solo crea comentario cuando el estado cambia" do
    record = Record.create!(id: "101::Puerta habitacion::Marco",
                            room: "101", category: "Puerta habitacion",
                            item: "Marco", status: :completado, report_date: Date.today,
                            user: users(:inspector_one))
    assert_difference "Comment.count", 1 do
      patch record_url(record),
            params: { record: { status: "defectuoso", room: "101",
                                category: "Puerta habitacion", item: "Marco",
                                owner: "MIFE", report_date: Date.today } },
            as: :turbo_stream
    end
    assert Comment.last.defectuoso?
  end

  test "no crea comentario cuando el estado no cambia" do
    Record.create!(id: "101::Puerta habitacion::Marco",
                   room: "101", category: "Puerta habitacion",
                   item: "Marco", status: :completado, report_date: Date.today,
                   user: users(:inspector_one))

    assert_no_difference "Comment.count" do
      patch record_url("101::Puerta habitacion::Marco"),
            params: { record: { status: "completado", room: "101",
                                category: "Puerta habitacion", item: "Marco",
                                owner: "MIFE", report_date: Date.today } },
            as: :turbo_stream
    end
  end

  test "responds with turbo stream replacing item frame, metrics and progress" do
    patch record_url("101::Puerta habitacion::Marco"),
          params: { record: { status: "completado", room: "101",
                              category: "Puerta habitacion", item: "Marco",
                              owner: "MIFE", report_date: Date.today } },
          as: :turbo_stream

    # El ítem actualizado
    assert_turbo_stream action: "replace", target: "record-101-marco"
    # Contadores de métricas
    assert_turbo_stream action: "replace", target: "room-metrics"
    # Porcentaje de avance
    assert_turbo_stream action: "replace", target: "topbar-progress"
  end
end
