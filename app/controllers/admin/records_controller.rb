# app/controllers/admin/records_controller.rb
module Admin
  class RecordsController < BaseController
    def index
      @records = Record.all
      @records = @records.where(room: params[:room])        if params[:room].present?
      @records = @records.where(status: params[:status])    if params[:status].present?
      @records = @records.where(report_date: params[:date]) if params[:date].present?
      @records = @records.order(updated_at: :desc).limit(200)
    end
  end
end
