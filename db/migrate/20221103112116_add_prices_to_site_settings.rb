class AddPricesToSiteSettings < ActiveRecord::Migration[6.0]
  def change
    add_column(:site_settings, :prices, :jsonb)
    SiteSettings.current.update!(
      electricity_price: 0.15,  # Value of BenchmarkMetrics::ELECTRICITY_PRICE as of 4/5/2023
      solar_export_price: 0.05, # Value of BenchmarkMetrics::SOLAR_EXPORT_PRICE as of 4/5/2023
      gas_price: 0.03          # Value of BenchmarkMetrics::GAS_PRICE as of 4/5/2023
    )
  end
end
