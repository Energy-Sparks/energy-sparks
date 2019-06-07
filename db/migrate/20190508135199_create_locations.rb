class CreateLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :locations do |t|
      t.references  :school,      null: false, foreign_key: { on_delete: :cascade }
      t.text        :name,        null: false
      t.timestamps
    end
  end
end
