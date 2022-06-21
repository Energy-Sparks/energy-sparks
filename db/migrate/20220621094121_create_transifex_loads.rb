class CreateTransifexLoads < ActiveRecord::Migration[6.0]
  def change
    create_table :transifex_loads do |t|
      t.integer :pushed
      t.integer :pulled

      t.timestamps
    end
  end
end
