class SolisCloudInverters < ActiveRecord::Migration[7.2]
  def change
    change_table(:solis_cloud_installations, bulk: true) do |t|
      t.remove_references :school, foreign_key: { on_delete: :cascade }
      t.remove :station_list, type: :jsonb
      t.column :inverter_detail_list, :jsonb, default: {}
    end
  end
end
