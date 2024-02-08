# == Schema Information
#
# Table name: comparison_reports
#
#  created_at                :datetime         not null
#  custom_current_period_id  :bigint(8)        not null
#  custom_previous_period_id :bigint(8)
#  id                        :bigint(8)        not null, primary key
#  key                       :string           not null
#  public                    :boolean          default(FALSE)
#  reporting_period          :integer
#  title                     :string           not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_comparison_reports_on_custom_current_period_id   (custom_current_period_id)
#  index_comparison_reports_on_custom_previous_period_id  (custom_previous_period_id)
#
# Foreign Keys
#
#  fk_rails_...  (custom_current_period_id => comparison_periods.id) ON DELETE => cascade
#  fk_rails_...  (custom_previous_period_id => comparison_periods.id) ON DELETE => cascade
#
class Comparison::Report < ApplicationRecord
  self.table_name = 'comparison_reports'

  extend Mobility

  validates :key, presence: true, uniqueness: true
  validates :title, :fuel_type, presence: true

  translates :title, type: :string, fallbacks: { cy: :en }
  translates :introduction, backend: :action_text
  translates :notes, backend: :action_text

  # These need deciding on. Add as needed?
  # [:last_12_months, :financial_year, :academic_year]
  enum reporting_period: { custom: 0 }

  belongs_to :custom_current_period, class_name: 'Comparison::Period'
  belongs_to :custom_previous_period, class_name: 'Comparison::Period'

  has_rich_text :introduction
  has_rich_text :notes
end
