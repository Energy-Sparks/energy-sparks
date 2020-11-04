class AddBackFillYearsToAreas < ActiveRecord::Migration[6.0]
  def change
    add_column :areas, :back_fill_years, :integer, default: 4
  end
end
