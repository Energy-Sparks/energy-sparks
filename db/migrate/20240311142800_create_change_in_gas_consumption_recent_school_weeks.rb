class CreateChangeInGasConsumptionRecentSchoolWeeks < ActiveRecord::Migration[6.1]
  def change
    create_view :change_in_gas_consumption_recent_school_weeks
  end
end
