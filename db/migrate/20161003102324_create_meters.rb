class CreateMeters < ActiveRecord::Migration[5.0]
  def change
    create_table :meters do |t|
      t.references :school, foreign_key: true
      t.integer :type, index: true
      t.integer :meter_no, index: true

      t.timestamps
    end
  end
end
