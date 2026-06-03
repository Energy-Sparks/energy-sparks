module Schools
  module Advice
    class CostsService
      def initialize(school, aggregate_school_service, fuel_type)
        @school = school
        @aggregate_school_service = aggregate_school_service
        @fuel_type = fuel_type
      end

      def complete_tariff_coverage?
        tariff_information_service.percentage_with_real_tariffs > 0.99
      end

      def periods_with_missing_tariffs
        tariff_information_service.periods_with_missing_tariffs
      end

      def multiple_meters?
        reporting_meters.length > 1
      end

      def annual_costs
        accounting_costs_service.annual_cost
      end

      def annual_costs_breakdown_by_meter
        breakdown = {}
        reporting_meters.each do |meter|
          breakdown[meter_for_mpan(meter.mpan_mprn)] = accounting_costs_service(meter).annual_cost
        end

        breakdown
      end

      # find the analytics meter for a given mpan
      def analytics_meter_for_mpan(mpan_mprn)
        meter_collection.meter?(mpan_mprn)
      end

      def calculate_costs_for_latest_twelve_months(meter = aggregate_meter)
        meter_costs_service(meter).calculate_costs_for_latest_twelve_months
      end

      def calculate_change_in_costs(meter = aggregate_meter)
        last_twelve_months = meter_costs_service(meter).calculate_costs_for_latest_twelve_months
        previous_twelve_months = meter_costs_service(meter).calculate_costs_for_previous_twelve_months
        last_twelve_months.map do |month, cost|
          year_previous = month.prev_year
          year_previous_costs = previous_twelve_months[year_previous]
          change = year_previous_costs.nil? ? nil : cost.total - year_previous_costs.total
          [month, change]
        end.to_h
      end

      def tariffs(analytics_meter)
        tariffs = tariff_information_service(analytics_meter).tariffs
        tariffs.map do |range, tariff|
          if tariff.real
            tariff.user_tariff = @school.energy_tariffs.where(name: tariff.name).first
          end
          [range, tariff]
        end
        tariffs.sort { |a, b| a[0].begin <=> b[0].begin}
      end

      def analysis_date_range
        [analysis_start_date, analysis_end_date]
      end

      private

      def meter_for_mpan(mpan_mprn)
        @school.meters.find_by_mpan_mprn(mpan_mprn)
      end

      def aggregate_meter
        meter_collection.aggregate_meter(@fuel_type)&.original_meter
      end

      def analysis_end_date(meter = aggregate_meter)
        meter.amr_data.end_date
      end

      def up_to_year_before_end_date(meter = aggregate_meter)
        [analysis_end_date(meter) - 365, meter.amr_data.start_date].max
      end

      def analysis_start_date(meter = aggregate_meter)
        [analysis_end_date(meter) - 365 - 364, meter.amr_data.start_date].max
      end

      def reporting_meters
        meter_collection.real_meters2.select { |m| m.fuel_type == @fuel_type }
      end

      def meter_costs_service(meter = aggregate_meter)
        Costs::MonthlyMeterCostsService.new(meter: meter)
      end

      def accounting_costs_service(meter = aggregate_meter)
        Costs::AccountingCostsService.new(meter, meter.amr_data.end_date)
      end

      def tariff_information_service(meter = aggregate_meter)
        @tariff_information_service ||= Costs::TariffInformationService.new(meter, analysis_start_date, analysis_end_date)
      end

      def meter_collection
        @aggregate_school_service.meter_collection
      end
    end
  end
end
