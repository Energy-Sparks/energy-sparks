class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.string :type, null: false, default: 'Note'
      t.string :title, null: false
      t.text :description, null: false
      t.integer :fuel_type
      t.integer :status
      t.references :school
      t.references :created_by, foreign_key: { to_table: 'users' }
      t.references :updated_by, foreign_key: { to_table: 'users' }

      t.timestamps
    end
  end
end
