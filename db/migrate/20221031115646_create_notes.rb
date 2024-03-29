class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.integer :note_type, default: 0, null: false
      t.string :title, null: false
      t.integer :fuel_type
      t.integer :status, default: 0, null: false
      t.references :school
      t.references :created_by, foreign_key: { to_table: 'users' }
      t.references :updated_by, foreign_key: { to_table: 'users' }

      t.timestamps
    end
  end
end
