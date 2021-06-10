class AddCredentialsToLowCarbonHub < ActiveRecord::Migration[6.0]
  def change
    add_column :low_carbon_hub_installations, :username, :string, default: nil
    add_column :low_carbon_hub_installations, :password, :string, default: nil
  end
end
