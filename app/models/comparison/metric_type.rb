class Comparison::MetricType < ApplicationRecord
  extend Mobility

  self.table_name = 'comparison_metric_types'

  translates :label, type: :string, fallbacks: { cy: :en }
  translates :description, type: :string, fallbacks: { cy: :en }

  validates :key, presence: true, uniqueness: true
  validates :label, :units, :fuel_type, presence: true

  # Originally called 'type', but this is usually used for STI in rails so not a good idea
  # Assume this really is so we know which unit to present along with the value?
  # i.e. :percent would be #{metric.value}%
  enum units: [:float, :date, :percent, :relative_percent]
  # are there more? [:£, :co2, :kwh, :time, :string, :kw]

  # wonder if we ought to have a fuel_types table at some point?
  enum fuel_type: [:electricity, :gas, :storage_heater, :solar_pv]
end
