class RemoveRecentChangesComparisons < ActiveRecord::Migration[6.1]
  def change
    drop_view :change_in_electricity_consumption_recent_school_weeks
    drop_view :change_in_gas_consumption_recent_school_weeks
  end
end
