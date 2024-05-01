# == Schema Information
#
# Table name: comparison_custom_periods
#
#  created_at           :datetime         not null
#  current_end_date     :date             not null
#  current_label        :string           not null
#  current_start_date   :date             not null
#  enough_days_data     :integer
#  id                   :bigint(8)        not null, primary key
#  max_days_out_of_date :integer
#  previous_end_date    :date             not null
#  previous_label       :string           not null
#  previous_start_date  :date             not null
#  updated_at           :datetime         not null
#
class Comparison::CustomPeriod < ApplicationRecord
  self.table_name = 'comparison_custom_periods'

  has_one :report, class_name: 'Comparison::Report', foreign_key: 'custom_period_id', inverse_of: :custom_period, dependent: :nullify

  validates :current_label, :current_start_date, :current_end_date, presence: true
  validates :previous_label, :previous_start_date, :previous_end_date, presence: true
  validates :max_days_out_of_date, :enough_days_data, presence: true

  # Rails 7 comparison validations (imported to: app/validators/comparison_validator.rb)
  # Basic rules. They could be more complex than this!
  validates :previous_end_date, comparison: { greater_than: :previous_start_date, message: 'must be greater than previous start date' }
  validates :current_start_date, comparison: { greater_than_or_equal_to: :previous_end_date, message: 'must be greater or equal to previous end date' }
  validates :current_end_date, comparison: { greater_than: :current_start_date, message: 'must be greater than current start date' }

  def to_s
    "comparing #{current_label} to #{previous_label}"
  end
end
