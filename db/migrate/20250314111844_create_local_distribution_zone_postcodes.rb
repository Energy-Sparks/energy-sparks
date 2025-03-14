class CreateLocalDistributionZonePostcodes < ActiveRecord::Migration[7.2]
  def change
    create_table :local_distribution_zone_postcodes do |t|
      t.references :local_distribution_zone
      t.string :postcode, index: { unique: true }
      t.timestamps
    end
  end
end
