class CreateSchools < ActiveRecord::Migration[5.0]
  def change
    create_table :schools do |t|
      t.string :name
      t.integer :type
      t.text :address
      t.string :postcode
      t.integer :eco_school_status
      t.string :website

      t.timestamps
    end
  end
end
