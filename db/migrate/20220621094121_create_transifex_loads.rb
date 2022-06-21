class CreateTransifexLoads < ActiveRecord::Migration[6.0]
  def change
    create_table :transifex_loads do |t|
      t.integer :pushed, default: 0, null: false
      t.integer :pulled, default: 0, null: false

      t.timestamps
    end
  end
end
