class CreateLocalDistributionZones < ActiveRecord::Migration[7.2]
  def change
    create_table :local_distribution_zones do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :publication_id, null: false
      t.timestamps
    end
  end
end
