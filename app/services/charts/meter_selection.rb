module Charts
  # Encapsulates presenting a list of meters used to populate the options for a form/chart
  #
  # So:
  #  - list of (displayable) meters
  #  - set of date ranges and label for each meter, to populate, e.g. subtitles and other chart options
  #
  # We often need to display lists of meters from the analytics, e.g. synthetic meters created for storage heaters,
  # aggregate meters, mains+self consume meters where there is solar
  #
  # So class works with a MeterCollection
  class MeterSelection
    attr_reader :school

    # meter_collection - use to extract list of meters
    # fuel type - fuel type of meters to list
    # include_whole_school - whether to include the aggregate meter as the whole school
    # date_window: if provided specified number of days for calculating date ranges
    def initialize(school, meter_collection, fuel_type, filter: nil, include_whole_school: true, date_window: nil, load_model: true)
      @school = school
      @meter_collection = meter_collection
      @fuel_type = fuel_type
      @include_whole_school = include_whole_school
      @date_window = date_window
      @filter = filter
    end

    def meter_selection_options
      @include_whole_school ? displayable_meters.prepend(aggregate_meter_adapter) : displayable_meters
    end

    def date_ranges_by_meter
      ranges_by_meter = {}
      displayable_meters.each do |analytics_meter|
        end_date = analytics_meter.amr_data.end_date
        start_date = start_date(analytics_meter)
        meter = @load_model ? @school.meters.find_by_mpan_mprn(analytics_meter.mpan_mprn) : nil
        ranges_by_meter[analytics_meter.mpan_mprn] = {
          meter: meter, # may be nil if synthetic meter or not loading models
          start_date: start_date,
          end_date: end_date
        }
      end
      if @include_whole_school
        ranges_by_meter[aggregate_meter_mpan_mprn] = {
          meter: aggregate_meter,
          label: aggregate_meter_label,
          start_date: [aggregate_meter.amr_data.end_date - 365, aggregate_meter.amr_data.start_date].max,
          end_date: aggregate_meter.amr_data.end_date
        }
      end
      ranges_by_meter
    end

    private

    def start_date(meter)
      earliest_date = meter.amr_data.start_date
      return earliest_date unless @date_window.present?

      desired_date = meter.amr_data.end_date - @date_window
      desired_date < earliest_date ? earliest_date : desired_date
    end

    def aggregate_meter
      @meter_collection.aggregate_meter(@fuel_type)
    end

    # TODO
    def aggregate_meter_label
      I18n.t('advice_pages.electricity_costs.analysis.meter_breakdown.whole_school')
    end

    def aggregate_meter_mpan_mprn
      aggregate_meter.mpan_mprn.to_s
    end

    def aggregate_meter_adapter
      OpenStruct.new(name_or_mpan_mprn: aggregate_meter_mpan_mprn, mpan_mprn: aggregate_meter_mpan_mprn, display_name: aggregate_meter_label)
    end

    def displayable_meters
      meters = case @fuel_type
               when :electricity
                 @meter_collection.electricity_meters
               when :gas
                 @meter_collection.heat_meters
               when :storage_heater, :storage_heaters
                 @meter_collection.storage_heater_meters # TODO likely not used
               else
                 raise 'Unexpected fuel type'
               end
      meters = meters.keep_if { |m| m.amr_data.any? } # only show meters with readings
      meters = meters.reject(&@filter) if @filter # apply optional filter
      meters.sort_by(&:mpan_mprn)
    end
  end
end
