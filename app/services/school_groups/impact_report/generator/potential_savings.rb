# frozen_string_literal: true

require 'dashboard'

module SchoolGroups
  module ImpactReport
    class Generator
      class PotentialSavings < Base
        METRIC_CATEGORY = :potential_savings
        ALERTS = {
          %i[electricity baseload] => AlertElectricityBaseloadVersusBenchmark,
          %i[electricity out_of_hours] => AlertOutOfHoursElectricityUsage,
          %i[electricity peak] => AlertElectricityPeakKWVersusBenchmark,
          %i[electricity use] => AlertElectricityAnnualVersusBenchmark,
          %i[gas heating_down] => AlertHeatingSensitivityAdvice,
          %i[gas heating_early] => AlertHeatingComingOnTooEarly,
          %i[gas heating_off] => AlertSeasonalHeatingSchoolDays,
          %i[gas insulate_pipes] => AlertHotWaterInsulationAdvice,
          %i[gas out_of_hours] => AlertOutOfHoursGasUsage,
          %i[gas thermostatic_control] => AlertThermostaticControl,
          %i[gas use] => AlertGasAnnualVersusBenchmark,
          %i[solar_pv solar_panels] => AlertSolarPVBenefitEstimator,
          %i[storage_heater heating_off] => AlertSeasonalHeatingSchoolDaysStorageHeaters
        }.freeze
        private_constant :ALERTS
        METRICS = ALERTS.keys.map(&:second).uniq.freeze

        def self.metric_names
          ALERTS.map { |(fuel_type, metric_type), alert| [{ metric_category:, metric_type:, fuel_type: }, alert] }
        end

        def metrics
          self.class.metric_names.map do |metric, alert|
            number_of_schools = actions[alert]&.schools&.count
            metric.merge(value: actions[alert]&.average_one_year_saving_gbp || 0,
                         number_of_schools: number_of_schools || 0,
                         unit: :gbp,
                         enough_data: number_of_schools.present?)
          end
        end

        private

        def actions
          @actions ||= SchoolGroups::PriorityActions
                       .new(visible_schools).total_savings
                       .transform_keys { |key| Object.const_get(key.alert_type.class_name) }
        end
      end
    end
  end
end
