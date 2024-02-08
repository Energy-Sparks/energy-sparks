# == Schema Information
#
# Table name: comparison_periods
#
#  created_at :datetime         not null
#  end_date   :date             not null
#  id         :bigint(8)        not null, primary key
#  label      :string           not null
#  start_date :date             not null
#  updated_at :datetime         not null
#
class Comparison::Period < ApplicationRecord
  self.table_name = 'comparison_periods'

  validates :label, :start_date, :end_date, presence: true
end
