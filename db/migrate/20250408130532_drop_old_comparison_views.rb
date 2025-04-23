class DropOldComparisonViews < ActiveRecord::Migration[7.2]
  def change
    drop_view :comparison_heat_saver_march_2024s, materialized: true
  end
end
