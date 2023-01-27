class AddFuelTypeToAdvicePages < ActiveRecord::Migration[6.0]
  def change
    add_column :advice_pages, :fuel_type, :integer
  end
end
