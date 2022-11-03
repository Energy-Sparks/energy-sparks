class AddPricesToSiteSettings < ActiveRecord::Migration[6.0]
  def change
    add_column(:site_settings, :prices, :jsonb)
    SiteSettings.current.update!(
      electricity_price: BenchmarkMetrics::ELECTRICITY_PRICE,
      solar_export_price: BenchmarkMetrics::SOLAR_EXPORT_PRICE,
      gas_price: BenchmarkMetrics::GAS_PRICE,
      oil_price: BenchmarkMetrics::OIL_PRICE
    )
  end
end
