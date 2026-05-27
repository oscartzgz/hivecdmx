# app/controllers/rooms_controller.rb
class RoomsController < ApplicationController
  def index
    @rooms = Checklist.rooms
  end

  def show
    @room     = params[:id]
    @category = params[:category] || Checklist.categories.first["name"]
    @records  = Record.where(room: @room).index_by(&:item)
    @items    = Checklist.items_for(@category)
    @sorted_items = @items.each_with_index.sort_by do |item, i|
      @records[item["name"]]&.checklist_sort_key(i) || i
    end.map(&:first)

    completed_count = @records.values.count(&:completado?)
    total_count     = Checklist.categories.sum { |c| c["items"].length }
    @progress_pct   = total_count > 0 ? (completed_count * 100 / total_count) : 0
  end
end
