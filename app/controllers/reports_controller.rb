# app/controllers/reports_controller.rb
class ReportsController < ApplicationController
  before_action :require_admin

  def show
    @room        = params[:room] || Checklist.rooms.first
    @date        = params[:date] || Date.today.to_s
    @records     = Record.where(room: @room, report_date: @date)
    @all_items   = Checklist.categories.flat_map { |c| c["items"].map { |i| i.merge("category" => c["name"]) } }
    @completed   = @records.select(&:completado?)
    @defective   = @records.select(&:defectuoso?)
    @with_notes  = @records.select { |r| r.note.present? }
    @total       = @all_items.length
    @pct         = @total > 0 ? (@completed.length * 100 / @total) : 0
  end

  def export
    @room    = params[:room] || Checklist.rooms.first
    @date    = params[:date] || Date.today.to_s
    @records = Record.where(room: @room, report_date: @date).index_by(&:item)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << %w[fecha habitacion categoria partida especialidad estatus observacion responsable]
      Checklist.categories.each do |cat|
        cat["items"].each do |item|
          record = @records[item["name"]]
          csv << [
            @date, @room, cat["name"], item["name"],
            item["owner"] || "",
            record&.status || "pendiente",
            record&.note || "",
            record&.inspector || ""
          ]
        end
      end
    end

    send_data csv_data,
              filename:     "avance-hab#{@room}-#{@date}.csv",
              type:         "text/csv;charset=utf-8",
              disposition:  "attachment"
  end
end
