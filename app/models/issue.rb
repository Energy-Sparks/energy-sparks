class Issue < ApplicationRecord
  include CsvExportable

  belongs_to :school
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  belongs_to :owned_by, class_name: 'User', optional: true

  scope :by_updated_at, -> { order(updated_at: :desc) }

  has_rich_text :description
  enum issue_type: { issue: 0, note: 1 }
  enum fuel_type: [:electricity, :gas, :solar]
  enum status: { open: 0, closed: 1 }, _prefix: true

  validates :issue_type, :status, :title, :description, presence: true

  def resolve!(attrs = {})
    self.attributes = attrs
    status_closed! if issue?
  end

  def resolvable?
    issue? && status_open?
  end

  def self.csv_headers
    ["School name", "Title", "Description", "Fuel type", "Created by", "Created at", "Updated by", "Updated at"]
  end

  def self.csv_attributes
    %w{school.name title description.to_plain_text fuel_type created_by.display_name created_at updated_by.display_name updated_at}
  end

  # From rails 6.1 onwards, a default for enums can be specified by setting by _default: :open or rails 7: default: :open on the enum definition
  # But until then we have to do this:
  after_initialize do
    self.issue_type ||= :issue
    self.status ||= :open
  end
end
