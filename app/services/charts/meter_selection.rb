module Charts
  # Encapsulates presenting a list of meters used to populate a select box for driving a MeterSelectionChartComponent
  #
  # Produces a list of objects that can be used to populate a select box using +options_from_collection_for_select+
  #
  # Also produces a hash of meters to date ranges that can be used to produce chart titles and subtitles that describe
  # the date ranges being shown on the chart.
  #
  # By default it will include all meters for the given fuel type that have readings. But supports options for
  # further filtering of the list of meters via the +filter+ option. Any meter for which the filter returns true will
  # be dropped from the list.
  #
  # Some charts include an option to show data for the entire school as well as individual meters. This can be configured
  # via the +include_whole_school+ option.
  #
  # The date ranges produced by +date+ranges_by_meter+ can be restricted using +date_window+
  #
  # Currently this class uses the meters returned from a MeterCollection rather than querying for meters from
  # the database.
  class MeterSelection
    attr_reader :school

    # meter_collection - use to extract list of meters
    # fuel type - fuel type of meters to list
    # include_whole_school - whether to include the aggregate meter as the whole school
    # date_window: if provided specified number of days for calculating date ranges
    def initialize(school,
                   meter_collection,
                   fuel_type,
                   filter: nil,
                   include_whole_school: true,
                   date_window: nil,
                   whole_school_label_key: 'advice_pages.charts.whole_school')
      @school = school
      @meter_collection = meter_collection
      @fuel_type = fuel_type
      @include_whole_school = include_whole_school
      @date_window = date_window
      @filter = filter
      @aggregate_meter_label = I18n.t(whole_school_label_key)
    end

    def meter_selection_options
      @include_whole_school ? displayable_meters.prepend(aggregate_meter_adapter) : displayable_meters
    end

    def date_ranges_by_meter
      ranges_by_meter = {}
      if @include_whole_school
        ranges_by_meter[aggregate_meter.mpan_mprn] = {
          meter: aggregate_meter_adapter,
          start_date: start_date(aggregate_meter),
          end_date: aggregate_meter.amr_data.end_date
        }
      end
      displayable_meters.each do |analytics_meter|
        end_date = analytics_meter.amr_data.end_date
        start_date = start_date(analytics_meter)
        ranges_by_meter[analytics_meter.mpan_mprn] = {
          meter: analytics_meter,
          start_date: start_date,
          end_date: end_date
        }
      end
      ranges_by_meter
    end

    private

    def aggregate_meter
      @meter_collection.aggregate_meter(@fuel_type)
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

    def start_date(meter)
      earliest_date = meter.amr_data.start_date
      return earliest_date unless @date_window.present?

      desired_date = meter.amr_data.end_date - @date_window
      desired_date < earliest_date ? earliest_date : desired_date
    end

    # Used to override default labelling methods for aggregate meter
    def aggregate_meter_adapter
      adapter = ActiveSupport::OrderedOptions.new
      adapter.name_or_mpan_mprn = aggregate_meter.mpan_mprn
      adapter.mpan_mprn = aggregate_meter.mpan_mprn
      adapter.display_name = @aggregate_meter_label
      adapter
    end
  end
end
