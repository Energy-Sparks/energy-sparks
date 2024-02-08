class Comparison::Period < ApplicationRecord
  self.table_name = 'comparison_periods'

  validates :label, :start_date, :end_date, presence: true
end
