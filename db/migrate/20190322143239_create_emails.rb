class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails do |t|
      t.references :contact, null: false, foreign_key: {on_delete: :cascade}
      t.datetime   :sent_at
      t.timestamps
    end
  end
end
