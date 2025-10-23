# == Schema Information
#
# Table name: comparison_reports
#
#  created_at       :datetime         not null
#  custom_period_id :bigint(8)
#  disabled         :boolean          default(FALSE), not null
#  fuel_type        :integer
#  id               :bigint(8)        not null, primary key
#  key              :string           not null
#  public           :boolean          default(FALSE)
#  report_group_id  :bigint(8)
#  reporting_period :integer
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_comparison_reports_on_custom_period_id  (custom_period_id)
#  index_comparison_reports_on_key               (key) UNIQUE
#  index_comparison_reports_on_report_group_id   (report_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (custom_period_id => comparison_custom_periods.id)
#  fk_rails_...  (report_group_id => comparison_report_groups.id)
#
class Comparison::Report < ApplicationRecord
  self.table_name = 'comparison_reports'

  extend Mobility
  include TransifexSerialisable
  include Enums::ReportingPeriod
  include Enums::FuelType
  extend FriendlyId

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :introduction, backend: :action_text
  translates :notes, backend: :action_text

  friendly_id :title, use: [:slugged], slug_column: :key

  def normalize_friendly_id(string)
    super.tr('-', '_')
  end

  belongs_to :custom_period, class_name: 'Comparison::CustomPeriod', optional: true, autosave: true, dependent: :destroy
  belongs_to :report_group, class_name: 'Comparison::ReportGroup'
  has_many :alerts, inverse_of: :comparison_report, dependent: :delete_all
  has_many :alert_errors, inverse_of: :comparison_report, dependent: :delete_all

  scope :by_title, ->(order = :asc) { i18n.order(title: order) }

  accepts_nested_attributes_for :custom_period, update_only: true, reject_if: :not_custom?

  before_validation -> { custom_period.try(:mark_for_destruction) if not_custom? }

  validates :custom_period, presence: true, if: :custom?
  validates :title, presence: true

  # Don't require this for now
  # validates :reporting_period, presence: true
  validates :key, presence: true, uniqueness: true

  scope :by_key, ->(order = :asc) { order(key: order) }

  def to_alert_configuration
    { name: title,
      max_days_out_of_date: custom_period.max_days_out_of_date,
      enough_days_data: custom_period.enough_days_data,
      current_period: custom_period.current_start_date..custom_period.current_end_date,
      previous_period: custom_period.previous_start_date..custom_period.previous_end_date,
      disable_normalisation: custom_period.disable_normalisation }
  end

  def self.fetch(key)
    find_by(key: key)
  end

  private

  def not_custom?
    !custom?
  end
end
