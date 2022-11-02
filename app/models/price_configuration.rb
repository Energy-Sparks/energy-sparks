# RailsSettings Model
class PriceConfiguration < RailsSettings::Base
  cache_prefix { "v1" }

  field :electricity_price, type: :float, default: BenchmarkMetrics::ELECTRICITY_PRICE, validates: { numericality: { greater_than_or_equal_to: 0.0 } }
  field :solar_export_price, type: :float, default: BenchmarkMetrics::SOLAR_EXPORT_PRICE, validates: { numericality: { greater_than_or_equal_to: 0.0 } }
  field :gas_price, type: :float, default: BenchmarkMetrics::GAS_PRICE, validates: { numericality: { greater_than_or_equal_to: 0.0 } }
  field :oil_price, type: :float, default: BenchmarkMetrics::OIL_PRICE, validates: { numericality: { greater_than_or_equal_to: 0.0 } }
end
