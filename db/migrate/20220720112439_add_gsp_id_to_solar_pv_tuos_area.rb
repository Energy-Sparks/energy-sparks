class AddGspIdToSolarPvTuosArea < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :gsp_id, :string, null: true
  end
end
