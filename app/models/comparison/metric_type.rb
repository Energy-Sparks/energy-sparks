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

  extend Mobility
  include EnumFuelType

  UNIT_TYPES = {
    float: 0,
    integer: 1,
    boolean: 2,
    string: 3,
    date: 4,
    kwh: 5,
    £: 6,
    £current: 7,
    co2: 8,
    kw: 9,
    percent: 10,
    relative_percent: 11,
    £_per_kw: 12,
    £_per_kwh: 13
  }.freeze

  enum units: UNIT_TYPES

  translates :label, type: :string, fallbacks: { cy: :en }
  translates :description, type: :string, fallbacks: { cy: :en }

  validates :key, presence: true, uniqueness: { scope: :fuel_type }
  validates :label, :units, :fuel_type, presence: true
end
