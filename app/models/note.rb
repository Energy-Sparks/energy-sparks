class Note < ApplicationRecord
  belongs_to :school
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  enum status: [:open, :closed], _default: "open"

  validates :title, :description, presence: true
end
