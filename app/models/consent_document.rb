class ConsentDocument < ApplicationRecord
  belongs_to :school
  has_one_attached :file
  has_rich_text :description
  validates_presence_of :school, :title, :file, presence: true
  scope :by_created_date, -> { order(created_at: :asc) }
end
