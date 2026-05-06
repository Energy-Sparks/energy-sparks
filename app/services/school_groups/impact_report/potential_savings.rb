# frozen_string_literal: true

module SchoolGroups
  class ImpactReport
    class PotentialSavings < Base
      ALERTS = {
        electricity_out_of_hours: AlertOutOfHoursElectricityUsage,
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
        insulate_pipes: AlertHotWaterInsulationAdvice
      }.freeze
      TYPES = %i[gbp co2 kwh].freeze
      TYPES_TO_METHOD = TYPES.zip(%i[average_one_year_saving_gbp one_year_saving_co2 one_year_saving_kwh]).to_h
      private_constant :ALERTS, :TYPES, :TYPES_TO_METHOD
      METRICS = ALERTS.keys.flat_map { |metric| TYPES.map { |suffix| [metric, suffix].join('_') } }.freeze

      def value(metric)
        metric, type = split_metric(metric)
        actions[ALERTS[metric]]&.public_send(TYPES_TO_METHOD[type])
      end

      def number_of_schools(metric)
        actions[ALERTS[split_metric(metric).first]]&.schools&.count
      end

      private

      def split_metric(metric)
        metric, _, type = metric.to_s.rpartition('_')
        [metric, type].map(&:to_sym)
      end

      def actions
        @actions ||= SchoolGroups::PriorityActions.new(@impact_report.visible_schools).total_savings
                                                  .transform_keys { |key| Object.const_get(key.alert_type.class_name) }
      end
    end
  end
end
