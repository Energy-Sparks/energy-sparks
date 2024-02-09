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
#  fk_rails_...  (custom_period_id => comparison_periods.id) ON DELETE => cascade
#
class Comparison::Report < ApplicationRecord
  self.table_name = 'comparison_reports'

  extend Mobility
  include EnumReportingPeriod

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :introduction, backend: :action_text
  translates :notes, backend: :action_text
  belongs_to :custom_period, class_name: 'Comparison::Period', optional: true

  validates :key, :title, :reporting_period, presence: true
  validates :custom_period, presence: true, if: :custom?
end
