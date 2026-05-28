# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :set_record

  def create
    @comment = @record.comments.build(comment_params)
    @comment.user = Current.user

    if @comment.save
      @checklist_item = Checklist.items_for(@record.category)
                                 .find { |i| i["name"] == @record.item } || {}
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to room_path(@record.room) }
      end
    else
      respond_to do |format|
        format.turbo_stream { head :unprocessable_entity }
        format.html { redirect_to room_path(@record.room), alert: @comment.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def set_record
    @record = Record.find(params[:record_id])
  end

  def comment_params
    params.require(:comment).permit(:body, :status, :photo)
  end
end
