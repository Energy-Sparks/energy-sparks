class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities do |t|
      t.references :school, foreign_key: true
      t.references :activity_type, foreign_key: true
      t.string :title
      t.text :description
      t.date :happened_on

      t.timestamps
    end
  end
end
