class CreateSimulationTable < ActiveRecord::Migration[5.2]
  def change
    create_table :simulations do |t|
      t.text        :title
      t.text        :notes
      t.references  :school,     foreign_key: true
      t.references  :user,       foreign_key: true
      t.text        :configuration
      t.boolean     :default
      t.timestamps
    end
  end
end
