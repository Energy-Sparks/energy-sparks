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

  delegated_type :issueable, types: %w[School SchoolGroup DataSource]
  delegate :name, to: :issueable
  belongs_to :school_group, -> { where(issues: { issueable_type: 'SchoolGroup' }) }, foreign_key: 'issueable_id', optional: true
  belongs_to :school, -> { where(issues: { issueable_type: 'School' }) }, foreign_key: 'issueable_id', optional: true

  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'
  belongs_to :owned_by, class_name: 'User', optional: true

  has_many :issue_meters, dependent: :destroy
  has_many :meters, through: :issue_meters

  scope :for_school_group, ->(school_group) do
    where(schools: { school_group: school_group }).or(
      where(school_group: school_group)).left_joins(:school)
  end

  scope :for_issue_types, ->(issue_types) { where(issue_type: issue_types) }
  scope :for_owned_by, ->(owned_by) { where(owned_by: owned_by) }
  scope :for_statuses, ->(statuses) { where(status: statuses) }

  scope :by_pinned, -> { order(pinned: :desc) }
  scope :by_status, -> { order(status: :asc) }
  scope :by_updated_at, -> { order(updated_at: :desc) }
  scope :by_priority_order, -> { by_pinned.by_status.by_updated_at }

  has_rich_text :description
  enum issue_type: { issue: 0, note: 1 }
  enum fuel_type: [:electricity, :gas, :solar, :gas_and_electricity, :alternative_heating]
  enum status: { open: 0, closed: 1 }, _prefix: true

  validates :issue_type, :status, :title, :description, presence: true
  validate :school_issue_meters_only

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
    ["For", "Name", "Title", "Description", "Fuel type", "Type", "Status", "Status summary", "Meters", "Meter status", "Data sources", "Owned by", "Created by", "Created at", "Updated by", "Updated at"]
  end

  def self.csv_attributes
    %w{issueable_type.titleize issueable.name title description.to_plain_text fuel_type issue_type status status_summary mpan_mprns admin_meter_statuses data_source_names owned_by.display_name created_by.display_name created_at updated_by.display_name updated_at}
  end

  def self.issue_type_images
    { issue: 'exclamation-circle', note: 'sticky-note' }
  end

  def self.issueable_images
    { school_group: 'users', school: 'school', data_source: 'download' }
  end

  def self.issue_type_classes
    { issue: 'danger', note: 'warning' }
  end

  def self.status_classes
    { open: 'info', closed: 'secondary' }
  end

  def status_summary
    issue? ? "#{status} issue" : "note"
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
    issueable_images[issueable.model_name.to_s.underscore.to_sym]
  end

  def mpan_mprns
    meters.map(&:mpan_mprn).compact.join('|').presence
  end

  def admin_meter_statuses
    labels = meters.map { |meter| meter.admin_meter_status&.label }
    return nil if labels.compact.empty?
    return labels.first if labels.uniq.size == 1
    labels.map { |label| label || 'None' }.join('|')
  end

  def data_source_names
    meters.map {|meter| meter.data_source.try(:name) }.compact.uniq.join('|').presence
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

  def school_issue_meters_only
    if meters.any? && !issueable.is_a?(School)
      errors.add(:base, "Only school issues can have associated meters")
    end
  end
end
