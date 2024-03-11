# frozen_string_literal: true

# == Schema Information
#
# Table name: change_in_electricity_consumption_recent_school_weeks
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
module Comparison
  class ChangeInElectricityConsumptionRecentSchoolWeeks < Comparison::View
  end
end
