class AddNameToMeters < ActiveRecord::Migration[5.0]
  def change
    add_column :meters, :name, :string
  end
end
