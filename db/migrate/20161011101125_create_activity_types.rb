class CreateActivityTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :activity_types do |t|
      t.string :name
      t.text :description
      t.boolean :active, default: true, index: true

      t.timestamps
    end
  end
end
