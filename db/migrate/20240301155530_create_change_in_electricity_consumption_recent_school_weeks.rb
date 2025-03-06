class CreateChangeInElectricityConsumptionRecentSchoolWeeks < ActiveRecord::Migration[6.1]
  def change
    create_view :change_in_electricity_consumption_recent_school_weeks
  end
end
