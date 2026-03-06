class CreateRegenerationErrors < ActiveRecord::Migration[7.2]
  def change
    create_table :regeneration_errors do |t|
      t.references :school, null: false, foreign_key: true
      t.text :message, null: false
      t.datetime :raised_at, null: false

      t.timestamps
    end
  end
end
