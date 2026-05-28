# app/controllers/rooms_controller.rb
class RoomsController < ApplicationController
  def index
    @rooms      = Checklist.rooms
    total_items = Checklist.categories.sum { |c| c["items"].length }

    raw = Record.group(:room, :status).count

    @room_stats = @rooms.index_with do |room|
      { completed: raw[[room, "completado"]] || 0,
        defective: raw[[room, "defectuoso"]]  || 0,
        total:     total_items }
    end

    @rooms_completed = @room_stats.count { |_, s| s[:total] > 0 && s[:completed] == s[:total] }
    @rooms_pending   = @rooms.length - @rooms_completed
    @global_pct      = @rooms.length > 0 ? (@rooms_completed * 100 / @rooms.length) : 0
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
