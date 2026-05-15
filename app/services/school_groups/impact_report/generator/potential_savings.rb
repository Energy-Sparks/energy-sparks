# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class Generator
      class PotentialSavings < Base
        def self.metric_type(base, type) = [base, type].join('_').to_sym

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
        TYPES = %i[gbp co2 kwh].freeze
        TYPES_TO_METHOD = TYPES.zip(%i[average_one_year_saving_gbp one_year_saving_co2 one_year_saving_kwh]).to_h
        private_constant :ALERTS, :TYPES, :TYPES_TO_METHOD
        METRICS = ALERTS.keys.flat_map do |_fuel_type, metric|
          TYPES.map { |type| metric_type(metric, type) }
        end.uniq.freeze

        def metrics
          ALERTS.flat_map do |(fuel_type, metric), alert|
            TYPES.map do |type|
              number_of_schools = actions[alert]&.schools&.count
              { fuel_type:,
                metric_type: self.class.metric_type(metric, type),
                metric_category: :potential_savings,
                value: value(alert, type),
                number_of_schools: number_of_schools || 0,
                enough_data: number_of_schools.present? }
            end
          end
        end

        private

        def value(alert, type) = actions[alert]&.public_send(TYPES_TO_METHOD[type]) || 0

        def actions
          @actions ||= SchoolGroups::PriorityActions
                       .new(@impact_report.visible_schools).total_savings
                       .transform_keys { |key| Object.const_get(key.alert_type.class_name) }
        end
      end
    end
  end
end
