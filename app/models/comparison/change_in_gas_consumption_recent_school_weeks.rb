# == Schema Information
#
# Table name: change_in_gas_consumption_recent_school_weeks
#
#  alert_generation_run_id :bigint(8)
#  difference_gbpcurrent   :float
#  difference_kwh          :float
#  difference_percent      :float
#  id                      :bigint(8)
#  pupils_changed          :boolean
#  school_id               :bigint(8)
#  tariff_has_changed      :boolean
#
class Comparison::ChangeInGasConsumptionRecentSchoolWeeks < Comparison::View
end
