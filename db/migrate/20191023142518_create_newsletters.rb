class CreateNewsletters < ActiveRecord::Migration[6.0]
  def change
    create_table :newsletters do |t|
      t.text :title,        null: false
      t.text :url,          null: false
      t.date :published_on, null: false
      t.timestamps
    end
  end
end
