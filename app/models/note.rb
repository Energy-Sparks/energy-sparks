class Note < ApplicationRecord
  belongs_to :school
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  enum type: [:note, :issue]
  enum fuel_type: [:electricity, :gas, :solar]
  enum status: { open: 0, closed: 1 }

  # From rails 6.1 onwards, a default can be specified by setting by _default: :open or rails 7: default: :open on the enum definition
  # But until then we have to do this:
  before_create :set_default_status

  validates :title, :description, presence: true

  private

  def set_default_status
    self.status ||= :open
  end
end
