# app/controllers/records_controller.rb
class RecordsController < ApplicationController
  before_action :set_record

  def update
    @checklist_item = checklist_item
    if @record.update(record_params)
      if @record.previously_new_record?
        # Primera vez: siempre registrar el estado inicial pendiente...
        @record.comments.create!(user: Current.user, status: :pendiente)
        # ...y si el inspector eligió un estado distinto, registrar también ese cambio
        @record.comments.create!(user: Current.user, status: @record.status) unless @record.pendiente?
      elsif @record.saved_change_to_status?
        # Record ya existía: solo registrar cambios posteriores
        @record.comments.create!(user: Current.user, status: @record.status)
      end

      # Recalcular métricas para el Turbo Stream que actualiza contadores y %
      @records      = Record.where(room: @record.room).index_by(&:item)
      total_count   = Checklist.categories.sum { |c| c["items"].length }
      completed_cnt = @records.values.count(&:completado?)
      @progress_pct = total_count > 0 ? (completed_cnt * 100 / total_count) : 0

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
    @record = Record.includes(comments: :user).find_or_initialize_by(id: params[:id])
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
    params.require(:record).permit(:status, :owner, :report_date)
  end

  def checklist_item
    Checklist.items_for(@record.category).find { |i| i["name"] == @record.item } || {}
  end
end
