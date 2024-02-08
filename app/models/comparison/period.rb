# == Schema Information
#
# Table name: comparison_periods
#
#  created_at          :datetime         not null
#  current_end_date    :date             not null
#  current_label       :string           not null
#  current_start_date  :date             not null
#  id                  :bigint(8)        not null, primary key
#  previous_end_date   :date             not null
#  previous_label      :string           not null
#  previous_start_date :date             not null
#  updated_at          :datetime         not null
#
class Comparison::Period < ApplicationRecord
  self.table_name = 'comparison_periods'

  validates :current_label, :current_start_date, :current_end_date, presence: true
  validates :previous_label, :previous_start_date, :previous_end_date, presence: true
end
