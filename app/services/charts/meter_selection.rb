# frozen_string_literal: true

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
  # Some charts include an option to show data for the entire school as well as individual meters. This can be
  # configured via the +include_whole_school+ option.
  #
  # The date ranges produced by +date+ranges_by_meter+ can be restricted using +date_window+
  #
  # Currently this class uses the meters returned from a MeterCollection rather than querying for meters from
  # the database.
  class MeterSelection
    attr_reader :school

    # @param School school the school whose data will be displayed
    # @param AggregateSchoolService service to access the meter_collection for school, used to find meters and data ranges
    # @param Symbol fuel_type specifies the fuel type of the meters to be selected
    # @param filter optional, a filter to be applied to list of meters, should return true for any to be dropped
    # @param boolean include_whole_school specifies whether there should be a "Whole school" option included in list
    # This will be based on the aggregate meter for the specified +fuel_type+
    # @param Integer date_window optional, used to build date ranges for each meter for dynamically populating sub
    # titles with date ranges
    # @param String whole_school_title_key, i18n key used for the meter name for the aggregate meter, if included
    # @param String whole_school_label_key, i18n key used for the display name for the aggregate meter, if included
    #
    # i18n-tasks-use t('advice_pages.charts.the_whole_school')
    # i18n-tasks-use t('advice_pages.charts.whole_school')
    def initialize(school,
                   aggregate_school_service,
                   fuel_type,
                   filter: nil,
                   include_whole_school: true,
                   date_window: nil,
                   whole_school_title_key: 'advice_pages.charts.the_whole_school',
                   whole_school_label_key: 'advice_pages.charts.whole_school')
      @school = school
      @aggregate_school_service = aggregate_school_service
      @fuel_type = fuel_type
      @include_whole_school = include_whole_school
      @date_window = date_window
      @filter = filter
      @whole_school_title_key = whole_school_title_key
      @whole_school_label_key = whole_school_label_key
    end

    def meter_selection_options
      @include_whole_school ? displayable_meters.prepend(aggregate_meter_adapter) : displayable_meters
    end

    def date_ranges_by_meter
      meters = []
      meters << [aggregate_meter, aggregate_meter_adapter] if @include_whole_school
      # if single meter, then the underlying meters is the aggregate meter
      # just return the range for aggregate adapter in this case so its labelled
      # correctly as "the whole school"
      meters.concat(displayable_meters) unless @include_whole_school && underlying_meters.count == 1
      meters.to_h do |meter, meter_adapter|
        [meter.mpan_mprn, { meter: meter_adapter || meter, start_date: start_date(meter), end_date: end_date(meter) }]
      end
    end

    def underlying_meters
      @underlying_meters ||= displayable_meters
    end

    def meter_collection
      @meter_collection ||= @aggregate_school_service.aggregate_school
    end

    private

    def aggregate_meter
      meter_collection.aggregate_meter(@fuel_type)
    end

    def displayable_meters
      meters = case @fuel_type
               when :electricity
                 meter_collection.electricity_meters
               when :gas
                 meter_collection.heat_meters
               when :storage_heater, :storage_heaters
                 meter_collection.storage_heater_meters # TODO: likely not used
               else
                 raise 'Unexpected fuel type'
               end
      meters.keep_if { |m| m.amr_data.any? } # only show meters with readings
      meters = meters.reject(&@filter) if @filter # apply optional filter
      meters.sort_by(&:mpan_mprn)
    end

    def start_date(meter)
      earliest_date = meter.amr_data.start_date
      return earliest_date if @date_window.blank?

      desired_date = meter.amr_data.end_date - @date_window
      [desired_date, earliest_date].max
    end

    def end_date(meter)
      meter.amr_data.end_date
    end

    # Used to override default labelling methods for aggregate meter
    def aggregate_meter_adapter
      adapter = ActiveSupport::OrderedOptions.new
      adapter.name_or_mpan_mprn = I18n.t(@whole_school_title_key)
      adapter.mpan_mprn = aggregate_meter.mpan_mprn
      adapter.display_name = I18n.t(@whole_school_label_key)
      adapter
    end
  end
end
