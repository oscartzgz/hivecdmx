# app/controllers/records_controller.rb
class RecordsController < ApplicationController
  before_action :set_record

  def update
    @checklist_item = checklist_item
    if @record.update(record_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to room_path(@record.room) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @record.frame_id,
            partial: "records/record",
            locals: { record: @record, item: @checklist_item, room: @record.room, category: @record.category }
          )
        end
        format.html { redirect_to room_path(@record.room), alert: @record.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def set_record
    @record = Record.find_or_initialize_by(id: params[:id])
    if @record.new_record?
      permitted = params.require(:record).permit(:room, :category, :item, :owner, :report_date)
      @record.assign_attributes(
        room:        permitted[:room],
        category:    permitted[:category],
        item:        permitted[:item],
        owner:       permitted[:owner],
        report_date: permitted[:report_date] || Date.today,
        inspector:   Current.user.name,
        user:        Current.user
      )
    end
  end

  def record_params
    params.require(:record).permit(:status, :note, :owner, :report_date)
  end

  def checklist_item
    Checklist.items_for(@record.category).find { |i| i["name"] == @record.item } || {}
  end
end
