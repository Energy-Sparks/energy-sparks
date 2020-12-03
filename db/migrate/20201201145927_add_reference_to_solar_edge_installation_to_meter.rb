class AddReferenceToSolarEdgeInstallationToMeter < ActiveRecord::Migration[6.0]
  def change
    add_reference :meters, :solar_edge_installation, foreign_key: { on_delete: :cascade }
  end
end
