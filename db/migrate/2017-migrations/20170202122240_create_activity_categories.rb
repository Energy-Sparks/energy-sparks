class CreateActivityCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :activity_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
