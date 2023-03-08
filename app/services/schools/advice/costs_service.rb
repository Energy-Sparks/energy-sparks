module Schools
  module Advice
    class CostsService
      def initialize(school, meter_collection, fuel_type)
        @school = school
        @meter_collection = meter_collection
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

      private

      def meter_for_mpan(mpan_mprn)
        @school.meters.find_by_mpan_mprn(mpan_mprn)
      end

      def aggregate_meter
        @meter_collection.aggregate_meter(@fuel_type)
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
        @meter_collection.real_meters2.select { |m| m.fuel_type == @fuel_type }
      end

      def accounting_costs_service(meter = aggregate_meter)
        Costs::AccountingCostsService.new(meter)
      end

      def tariff_information_service(meter = aggregate_meter)
        @tariff_information_service ||= Costs::TariffInformationService.new(meter, analysis_start_date, analysis_end_date)
      end
    end
  end
end
