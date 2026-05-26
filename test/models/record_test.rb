# test/models/record_test.rb
require "test_helper"

class RecordTest < ActiveSupport::TestCase
  test "pendiente by default" do
    r = Record.new(id: "101::Puerta habitacion::Marco",
                   room: "101", category: "Puerta habitacion",
                   item: "Marco", report_date: Date.today)
    assert r.valid?
    assert r.pendiente?
  end

  test "checklist_sort_key puts pendiente before completado" do
    pending_record   = Record.new(status: :pendiente)
    completed_record = Record.new(status: :completado)
    assert pending_record.checklist_sort_key(0) < completed_record.checklist_sort_key(0)
  end

  test "checklist_sort_key preserves yaml order within same status" do
    r1 = Record.new(status: :pendiente)
    r2 = Record.new(status: :pendiente)
    assert r1.checklist_sort_key(0) < r2.checklist_sort_key(1)
  end

  test "frame_id is stable and DOM-safe" do
    r = Record.new(room: "101", item: "Marco")
    assert_match(/\Arecord-101-/, r.frame_id)
    assert_no_match(/:/, r.frame_id)
  end
end
