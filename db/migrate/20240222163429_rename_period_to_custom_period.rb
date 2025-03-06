class RenamePeriodToCustomPeriod < ActiveRecord::Migration[6.1]
  def change
    rename_table :comparison_periods, :comparison_custom_periods
  end
end
