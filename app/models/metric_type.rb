class MetricType < ApplicationRecord
  translates :label, type: :string, fallbacks: { cy: :en }
  translates :description, type: :string, fallbacks: { cy: :en }

  # We may be asking for trouble calling this column 'type'. We shall see!
  # Could be units ?
  enum type: [:float, :date, :percent, :relative_percent]
  # are there more? [:£, :co2, :kwh, :time, :string, :kw, :boolean]

  # wonder if we ought to have a fuel_types table at some point?
  enum fuel_type: [:electricity, :gas, :storage_heater, :solar_pv]
end
