class AddGspIdToSolarPvTuosArea < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :gsp_name, :string, null: true
  end
end
