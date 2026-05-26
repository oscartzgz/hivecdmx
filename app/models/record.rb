# app/models/record.rb
class Record < ApplicationRecord
  self.primary_key = "id"

  belongs_to :user, optional: true
  has_many_attached :photos

  enum :status, { pendiente: 0, defectuoso: 1, completado: 2 }, default: :pendiente

  validates :room,        presence: true
  validates :category,    presence: true
  validates :item,        presence: true
  validates :report_date, presence: true
  validates :note,        length: { maximum: 2000 }
  validates :inspector,   length: { maximum: 120 }
  validate  :max_three_photos

  STATUS_SORT = { "pendiente" => 0, "defectuoso" => 1, "completado" => 2 }.freeze

  def checklist_sort_key(yaml_index)
    STATUS_SORT[status] * 10_000 + yaml_index
  end

  def frame_id
    "record-#{room}-#{item.parameterize}"
  end

  private

  def max_three_photos
    errors.add(:photos, "máximo 3 fotos por partida") if photos.count > 3
  end
end
