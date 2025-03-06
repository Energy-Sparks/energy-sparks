class UpdateConfigurablePeriodsToVersion3 < ActiveRecord::Migration[7.1]
  def change
    update_view :configurable_periods, version: 3, revert_to_version: 2
  end
end
