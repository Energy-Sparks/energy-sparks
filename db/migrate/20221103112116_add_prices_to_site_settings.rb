class AddPricesToSiteSettings < ActiveRecord::Migration[6.0]
  def change
    add_column(:site_settings, :prices, :jsonb)
  end
end
