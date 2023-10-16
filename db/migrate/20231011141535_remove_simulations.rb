class RemoveSimulations < ActiveRecord::Migration[6.0]
  def change
    drop_table :simulations
  end
end
