class CreateJobs < ActiveRecord::Migration[6.0]
  def change
    create_table :jobs do |t|
      t.string :title, null: false
      t.boolean :voluntary, default: false
      t.date :closing_date
      t.timestamps
    end
  end
end
