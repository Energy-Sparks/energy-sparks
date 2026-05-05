# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class PotentialSavings < Base
      ALERTS = { electricity_out_of_hours: AlertOutOfHoursElectricityUsage,
                 electricity_peak: AlertElectricityPeakKWVersusBenchmark,
                 electricity_use: AlertElectricityAnnualVersusBenchmark,
                 electricity_baseload: AlertElectricityBaseloadVersusBenchmark,
                 solar_panels: AlertSolarPVBenefitEstimator,
                 thermostatic_control: AlertThermostaticControl,
                 gas_out_of_hours: AlertOutOfHoursGasUsage,
                 gas_use: AlertGasAnnualVersusBenchmark,
                 heating_early: AlertHeatingComingOnTooEarly,
                 heating_down: AlertHeatingSensitivityAdvice,
                 heating_off: AlertSeasonalHeatingSchoolDays,
                 storage_heaters_off: AlertSeasonalHeatingSchoolDaysStorageHeaters,
                 insulate_pipes: AlertHotWaterInsulationAdvice }.freeze
      TYPES = %i[gbp co2 kwh].freeze
      private_constant :ALERTS, :TYPES
      METRICS = ALERTS.keys.flat_map { |metric| TYPES.map { |suffix| [metric, suffix].join('_') } }

      ALERTS.each do |metric, alert|
        define_method("#{metric}_gbp") do
          actions[alert]&.average_one_year_saving_gbp
        end
        define_method("#{metric}_co2") do
          actions[alert]&.one_year_saving_co2
        end
        define_method("#{metric}_kwh") do
          actions[alert]&.one_year_saving_kwh
        end
      end

      def number_of_schools(metric)
        actions[ALERTS[metric.to_s.rpartition('_').first.to_sym]]&.schools&.length
      end

      private

      def actions
        @actions ||= SchoolGroups::PriorityActions.new(@impact_report.visible_schools).total_savings
                                                  .transform_keys { |key| Object.const_get(key.alert_type.class_name) }
      end
    end
  end
end
