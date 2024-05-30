class UpdateConfigurablePeriodsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :configurable_periods, version: 2, revert_to_version: 1
  end
end
