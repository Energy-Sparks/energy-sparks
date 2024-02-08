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
# Indexes
#
#  index_comparison_metric_types_on_key_and_fuel_type  (key,fuel_type) UNIQUE
#
class Comparison::MetricType < ApplicationRecord
  self.table_name = 'comparison_metric_types'

  include EnumFuelType
  extend Mobility

  translates :label, type: :string, fallbacks: { cy: :en }
  translates :description, type: :string, fallbacks: { cy: :en }

  validates :key, presence: true, uniqueness: { scope: :fuel_type }
  validates :label, :units, :fuel_type, presence: true

  enum units: [:float, :date, :percent, :relative_percent]
  # are there more? [:£, :co2, :kwh, :time, :string, :kw]
end
