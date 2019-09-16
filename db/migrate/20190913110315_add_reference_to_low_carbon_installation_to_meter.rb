class AddReferenceToLowCarbonInstallationToMeter < ActiveRecord::Migration[6.0]
  def change
    add_reference :meters, :low_carbon_hub_installation, foreign_key: { on_delete: :cascade }
  end
end
