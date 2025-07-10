class SolarPVPanelConfiguration
  MIN_DEFAULT_START_DATE = Date.new(2010, 1, 1)
  MAX_DEFAULT_END_DATE   = Date.new(2050, 1, 1)

  attr_reader :config_by_date_range

  def initialize(meter_attributes_config, default)
    @config_by_date_range = {} # date_range = config
    parse_meter_attributes_configuration(meter_attributes_config)
    @default = default
  end

  def first_installation_date
    config_by_date_range.keys.first.first
  end

  def degraded_kwp(date, override_key)
    @degraded_kwp ||= {}
    @degraded_kwp[date] ||= {}
    @degraded_kwp[date][override_key] ||= degraded_capacity_on_date_kw(date, override_key)
  end

  private

  def degraded_capacity_on_date_kw(date, override_key)
    degraded_capacity = 0.0
    # select panel capacities where they were installed on the given date
    # and we're configured to override. Note: this is called for both
    # :solar_pv and :solar_pv_override meter attributes. The former has no
    # override attributes, so we default to true if not set.
    panel_set_capacities = @config_by_date_range.select do |dates, config|
      date.between?(dates.first, dates.last) && config.fetch(override_key, @default)
    end
    return nil if panel_set_capacities.empty?

    panel_set_capacities.each do |date_range, panel_set_config|
      degraded_capacity += panel_set_config[:kwp] * degredation(date_range.first, date)
    end
    degraded_capacity
  end

  def degredation(from_date, to_date)
    years = (to_date - from_date) / 365.0
    # allow 0.5% degredation per year
    (1.0 - 0.005)**years
  end

  def parse_meter_attributes_configuration(meter_attributes_config)
    raise EnergySparksMeterSpecification, ':solar_pv: attribute not setup' if meter_attributes_config.nil?

    if meter_attributes_config.is_a?(Array)
      meter_attributes_config.each do |period_config|
        @config_by_date_range.merge!(parse_meter_attributes_configuration_for_period(period_config))
      end
    else
      raise EnergySparksMeterSpecification,
            'Unexpected meter attributes for solar pv, expecting array of hashes or 1 hash'
    end
  end

  def parse_meter_attributes_configuration_for_period(period_config)
    start_date = !period_config.nil? && period_config.key?(:start_date) ? period_config[:start_date] : MIN_DEFAULT_START_DATE
    end_date   = !period_config.nil? && period_config.key?(:end_date) ? period_config[:end_date] : MAX_DEFAULT_END_DATE

    # will need a case statement at some point to parse this properly? TODO(PH,21Mar2019)
    data_fields = %i[kwp orientation tilt shading fit_£_per_kwh override_generation override_export
                     override_self_consume maximum_export_level_kw]
    config = period_config.select { |param, _value| data_fields.include?(param) }

    { start_date..end_date => config }
  end
end
