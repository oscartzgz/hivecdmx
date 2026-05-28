# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :record, foreign_key: :record_id, primary_key: :id
  belongs_to :user
  has_one_attached :photo

  enum :status, { pendiente: 0, defectuoso: 1, completado: 2 }, default: :pendiente

  validates :status, presence: true

  scope :chronological, -> { order(:created_at, :id) }
end
