class AddLoadTariffsToDataSource < ActiveRecord::Migration[6.1]
  def change
    add_column :data_sources, :load_tariffs, :boolean, null: false, default: true
  end
end
