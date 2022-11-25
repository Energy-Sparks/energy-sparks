# == Schema Information
#
# Table name: issues
#
#  created_at     :datetime         not null
#  created_by_id  :bigint(8)
#  fuel_type      :integer
#  id             :bigint(8)        not null, primary key
#  issue_type     :integer          default("issue"), not null
#  issueable_id   :bigint(8)
#  issueable_type :string
#  owned_by_id    :bigint(8)
#  pinned         :boolean          default(FALSE)
#  status         :integer          default("open"), not null
#  title          :string           not null
#  updated_at     :datetime         not null
#  updated_by_id  :bigint(8)
#
# Indexes
#
#  index_issues_on_created_by_id                    (created_by_id)
#  index_issues_on_issueable_type_and_issueable_id  (issueable_type,issueable_id)
#  index_issues_on_owned_by_id                      (owned_by_id)
#  index_issues_on_updated_by_id                    (updated_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (created_by_id => users.id)
#  fk_rails_...  (owned_by_id => users.id)
#  fk_rails_...  (updated_by_id => users.id)
#
class Issue < ApplicationRecord
  include CsvExportable

  delegated_type :issueable, types: %w[School SchoolGroup]
  delegate :name, to: :issueable

  belongs_to :school_group, -> { where(issues: { issueable_type: 'SchoolGroup' }) }, foreign_key: 'issueable_id', optional: true
  belongs_to :school, -> { where(issues: { issueable_type: 'School' }) }, foreign_key: 'issueable_id', optional: true

  scope :for_school_group, ->(school_group) do
    where(schools: { school_group: school_group }).or(
      where(school_group: school_group)).left_joins(:school)
  end

  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  belongs_to :owned_by, class_name: 'User', optional: true

  scope :by_updated_at, -> { order(updated_at: :desc) }
  scope :by_pinned, -> { order(pinned: :desc) }

  has_rich_text :description
  enum issue_type: { issue: 0, note: 1 }
  enum fuel_type: [:electricity, :gas, :solar]
  enum status: { open: 0, closed: 1 }, _prefix: true

  validates :issue_type, :status, :title, :description, presence: true

  before_save :set_note_status
  after_initialize :set_enum_defaults

  def resolve!(attrs = {})
    self.attributes = attrs
    status_closed! if issue?
  end

  def resolvable?
    issue? && status_open?
  end

  def self.csv_headers
    ["Issue type", "Name", "Title", "Description", "Fuel type", "Created by", "Created at", "Updated by", "Updated at"]
  end

  def self.csv_attributes
    %w{issueable_type issueable.name title description.to_plain_text fuel_type created_by.display_name created_at updated_by.display_name updated_at}
  end

  def self.issue_type_images
    { issue: 'exclamation-circle', note: 'sticky-note' }
  end

  def self.issueable_images
    { school_group: 'users', school: 'school' }
  end

  def issue_type_image
    self.class.issue_type_image(issue_type)
  end

  def issueable_image
    issueable ? self.class.issueable_image(issueable) : ''
  end

  def self.issue_type_image(issue_type)
    issue_type_images[issue_type.to_sym]
  end

  def self.issueable_image(issueable)
    issueable_images[issueable.model_name.to_s.downcase.to_sym]
  end

  private

  # From rails 6.1 onwards, a default for enums can be specified by setting by _default: :open or rails 7: default: :open on the enum definition
  # But until then we have to do this:
  def set_enum_defaults
    self.issue_type ||= :issue
    self.status ||= :open
  end

  def set_note_status
    self.status = :open if self.note?
  end
end
