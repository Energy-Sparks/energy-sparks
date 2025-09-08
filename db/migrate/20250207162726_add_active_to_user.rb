class AddActiveToUser < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :active, :boolean, null: false, default: true
  end
end
