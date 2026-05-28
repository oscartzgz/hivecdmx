# app/controllers/rooms_controller.rb
class RoomsController < ApplicationController
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

  def show
    @room     = params[:id]
    @category = params[:category] || Checklist.categories.first["name"]
    @records  = Record.where(room: @room).includes(comments: :user).index_by(&:item)
    @items    = Checklist.items_for(@category)
    @sorted_items = @items.each_with_index.sort_by do |item, i|
      @records[item["name"]]&.checklist_sort_key(i) || i
    end.map(&:first)

    completed_count = @records.values.count(&:completado?)
    total_count     = Checklist.categories.sum { |c| c["items"].length }
    @progress_pct   = total_count > 0 ? (completed_count * 100 / total_count) : 0
  end
end
