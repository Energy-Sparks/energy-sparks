class RemoveEarliestAvailableData < ActiveRecord::Migration[6.1]
  def change
    remove_column :meters, :earliest_available_data, :date
  end
end
