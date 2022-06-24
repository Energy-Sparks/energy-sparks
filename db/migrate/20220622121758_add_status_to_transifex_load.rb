class AddStatusToTransifexLoad < ActiveRecord::Migration[6.0]
  def change
    add_column :transifex_loads, :status, :integer, null: false, default: 0
  end
end
