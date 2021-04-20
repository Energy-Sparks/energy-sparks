class ChangeTariffPricesToYaml < ActiveRecord::Migration[6.0]
  def change
    ActiveRecord::Base.connection.execute("TRUNCATE tariff_standing_charges RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE tariff_prices RESTART IDENTITY")
    ActiveRecord::Base.connection.execute("TRUNCATE tariff_import_logs RESTART IDENTITY")
    remove_column :tariff_prices, :prices, :json, default: {}
    add_column :tariff_prices, :prices, :text, default: nil
  end
end
