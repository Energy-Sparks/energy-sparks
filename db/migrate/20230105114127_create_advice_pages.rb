class CreateAdvicePages < ActiveRecord::Migration[6.0]
  def change
    create_table :advice_pages do |t|
      t.string :key, null: false, index: {unique: true}
      t.boolean :restricted, default: false

      t.timestamps
    end
  end
end
