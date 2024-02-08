# == Schema Information
#
# Table name: comparison_metric_types
#
#  created_at :datetime         not null
#  fuel_type  :integer          not null
#  id         :bigint(8)        not null, primary key
#  key        :string           not null
#  units      :integer          not null
#  updated_at :datetime         not null
#
class Comparison::MetricType < ApplicationRecord
  self.table_name = 'comparison_metric_types'

  include EnumFuelTypeable
  extend Mobility

  translates :label, type: :string, fallbacks: { cy: :en }
  translates :description, type: :string, fallbacks: { cy: :en }

  validates :key, presence: true, uniqueness: true
  validates :label, :units, :fuel_type, presence: true

  # Originally called 'type', but this is usually used for STI in rails so not a good idea
  # Assume this really is so we know which unit to present along with the value?
  # i.e. :percent would be #{metric.value}%
  enum units: [:float, :date, :percent, :relative_percent]
  # are there more? [:£, :co2, :kwh, :time, :string, :kw]
end
