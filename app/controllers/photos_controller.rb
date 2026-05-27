class PhotosController < ApplicationController
  before_action :set_record

  ALLOWED_TYPES   = %w[image/jpeg image/png image/webp].freeze
  MAX_SIZE_BYTES  = 5.megabytes
  MAX_PHOTOS      = 3

  def create
    return render_error("Formato no válido") unless valid_type?
    return render_error("Archivo muy grande (máx 5 MB)") unless valid_size?
    return render_error("Máximo #{MAX_PHOTOS} fotos por partida") if at_limit?

    @record.photos.attach(params[:file])

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to room_path(@record.room) }
    end
  end

  def show
    photo = @record.photos.find(params[:id])
    redirect_to url_for(photo), allow_other_host: false
  end

  private

  def set_record
    @record = Record.find(params[:record_id])
  end

  def valid_type?
    ALLOWED_TYPES.include?(params[:file]&.content_type)
  end

  def valid_size?
    params[:file]&.size.to_i <= MAX_SIZE_BYTES
  end

  def at_limit?
    @record.photos.size >= MAX_PHOTOS
  end

  def render_error(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "#{@record.frame_id}-photo-error",
          html: "<span style='color:var(--color-defective);font-size:var(--font-size-sm)'>#{message}</span>"
        )
      end
      format.html { redirect_to room_path(@record.room), alert: message }
    end
  end
end
