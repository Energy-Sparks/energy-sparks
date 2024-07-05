class AddMultipleMetersFlagToAdvicePage < ActiveRecord::Migration[7.0]
  def change
    add_column :advice_pages, :multiple_meters, :boolean, null: false, default: false
  end
end
