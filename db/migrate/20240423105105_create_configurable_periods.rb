class CreateConfigurablePeriods < ActiveRecord::Migration[6.1]
  def change
    create_view :configurable_periods
  end
end
