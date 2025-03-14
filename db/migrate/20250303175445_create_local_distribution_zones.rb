class CreateLocalDistributionZones < ActiveRecord::Migration[7.2]
  def change
    create_table :local_distribution_zones do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :code, null: false, index: { unique: true }
      t.string :publication_id, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :local_distribution_zone_readings do |t|
      t.date :date, null: false
      t.float :calorific_value, null: false
      t.references :local_distribution_zone
      t.index %i[local_distribution_zone_id date], unique: true
      t.timestamps
    end
  end
end
