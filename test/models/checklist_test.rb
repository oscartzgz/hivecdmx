# test/models/checklist_test.rb
require "test_helper"

class ChecklistTest < ActiveSupport::TestCase
  test "loads categories" do
    assert_equal 8, Checklist.categories.length
  end

  test "first category is Puerta habitacion" do
    assert_equal "Puerta habitacion", Checklist.categories.first["name"]
  end

  test "items_for returns items for a category" do
    items = Checklist.items_for("Carpinteria")
    assert_equal 6, items.length
    assert_equal "Escritorio", items.first["name"]
  end

  test "items_for returns empty array for unknown category" do
    assert_empty Checklist.items_for("Inexistente")
  end

  test "rooms returns all room numbers as strings" do
    rooms = Checklist.rooms
    assert_includes rooms, "101"
    assert_includes rooms, "910"
    assert_equal 155, rooms.length
  end

  test "composite_key builds lookup key" do
    assert_equal "101::Puerta habitacion::Marco", Checklist.composite_key("101", "Puerta habitacion", "Marco")
  end
end
