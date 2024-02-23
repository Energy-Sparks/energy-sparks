# == Schema Information
#
# Table name: comparison_reports
#
#  created_at       :datetime         not null
#  custom_period_id :bigint(8)
#  id               :bigint(8)        not null, primary key
#  key              :string           not null
#  public           :boolean          default(FALSE)
#  reporting_period :integer
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_comparison_reports_on_custom_period_id  (custom_period_id)
#  index_comparison_reports_on_key               (key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (custom_period_id => comparison_custom_periods.id)
#
class Comparison::Report < ApplicationRecord
  self.table_name = 'comparison_reports'

  extend Mobility
  include EnumReportingPeriod

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :introduction, backend: :action_text
  translates :notes, backend: :action_text

  belongs_to :custom_period, class_name: 'Comparison::CustomPeriod', optional: true, autosave: true, dependent: :destroy
  accepts_nested_attributes_for :custom_period, update_only: true, reject_if: :not_custom?

  before_validation -> { custom_period.try(:mark_for_destruction) if not_custom? }

  validates :custom_period, presence: true, if: :custom?
  validates :title, :reporting_period, presence: true
  validates :key, presence: true, uniqueness: true

  scope :by_key, ->(order = :asc) { order(key: order) }

  private

  def not_custom?
    !custom?
  end
end
