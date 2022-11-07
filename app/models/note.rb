class Note < ApplicationRecord
  belongs_to :school
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  scope :by_updated_at, -> { order(updated_at: :desc) }

  has_rich_text :description
  enum note_type: { note: 0, issue: 1 }
  enum fuel_type: [:electricity, :gas, :solar]
  enum status: { open: 0, closed: 1 }

  validates :note_type, :status, :title, :description, presence: true

  # From rails 6.1 onwards, a default for enums can be specified by setting by _default: :open or rails 7: default: :open on the enum definition
  # But until then we have to do this:
  after_initialize do
    self.note_type ||= :note
    self.status ||= :open
  end
end
