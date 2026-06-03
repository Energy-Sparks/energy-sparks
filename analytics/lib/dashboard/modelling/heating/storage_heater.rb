# StorageHeaters are a group of StorageHeaterDefinition
# to allow for a mix of heaters in any given school
# with different time controls, or a change in their
# setup over time
class StorageHeater
  class OverlappingStorageHeaterTimeConfigs < StandardError; end
  include Logging

  def initialize(meter_attributes_config)
    @storage_heater_config = StorageHeaterConfiguration.new(meter_attributes_config)
  end

  def disaggregate_amr_data(amr_data, mpan_mprn)
    storage_heater_amr_data = AMRData.new(:storage_heater)
    electricity_only_amr_data = AMRData.new(:electricity)
    mpan_mprn_storage_heater = mpan_mprn # TODO PH 20Mar2019 - create unique mpan for synthetic meter
    mpan_mprn_electric_only  = mpan_mprn # TODO PH 20Mar2019 - create unique mpan for synthetic meter

    (amr_data.start_date..amr_data.end_date).each do |date|
      if @storage_heater_config.in_operation?(date)
        storage_heater_kwh, electric_only_kwh = disaggregate_one_day(date, amr_data)

        sh_type = amr_data.substitution_type(date) == 'ORIG' ? 'STOR' : 'STRO'
        e_type  = amr_data.substitution_type(date) == 'ORIG' ? 'STEX' : 'STXE'

        storage_heater_amr_data.add(  date, OneDayAMRReading.new(mpan_mprn_storage_heater, date, sh_type, nil, DateTime.now, storage_heater_kwh))
        electricity_only_amr_data.add(date, OneDayAMRReading.new(mpan_mprn_electric_only,  date, e_type, nil, DateTime.now, electric_only_kwh))
      else # non storage heater day, just copy days kwh data
        electricity_only_amr_data.add(date, amr_data.clone_one_days_data(date))
      end
    end
    logger.debug { "Disaggregated storage heater #{amr_data.total.round(0)} kWh => sh #{storage_heater_amr_data.total.round(0)} e-sh #{electricity_only_amr_data.total.round(0)}" }

    [electricity_only_amr_data, storage_heater_amr_data]
  end

  private

  def disaggregate_one_day(date, amr_data)
    storage_heater_kwh = Array.new(48, 0.0)
    electric_only_kwh = Array.new(48, 0.0)

    baseload_sample_date = date > amr_data.start_date ? date - 1 : date
    baseload_kwh = amr_data.statistical_baseload_kw(baseload_sample_date) / 2.0
    (0..47).each do |halfhour_index|
      kwh = amr_data.kwh(date, halfhour_index)
      if storage_heater_on?(amr_data, date, halfhour_index, baseload_kwh)
        storage_heater_kwh[halfhour_index] = [kwh - baseload_kwh, 0.0].max
        electric_only_kwh[halfhour_index] = [kwh, baseload_kwh].min
      else
        electric_only_kwh[halfhour_index] = kwh
      end
    end

    [storage_heater_kwh, electric_only_kwh]
  end

  def capacity_at_time_of_day_deprecated(date, halfhour_index)
    capacity = 0.0
    @storage_heaters.each do |storage_heater|
      _d, start_time_halfhour_index = DateTimeHelper.time_to_date_and_half_hour_index(storage_heater.start_time)
      _d, end_time_halfhour_index = DateTimeHelper.time_to_date_and_half_hour_index(storage_heater.end_time)
      next if storage_heater.timer == :day7 && date.saturday?
      next if storage_heater.timer == :day7 && date.sunday? && start_time_halfhour_index < end_time_halfhour_index
      if start_time_halfhour_index < end_time_halfhour_index &&
        halfhour_index >= start_time_halfhour_index &&
        halfhour_index <= end_time_halfhour_index
        capacity += storage_heater.kwp
      elsif start_time_halfhour_index > end_time_halfhour_index
        (halfhour_index >= start_time_halfhour_index || # storage heater set to start before midnight
        halfhour_index <= end_time_halfhour_index)
        capacity += storage_heater.kwp
      end
    end
    capacity
  end

  def max_capacity_kw_on_day_deprecated(date)
    total_capacity = 0.0
    storage_heaters.each do |storage_heater|
      if storage_heater.start_date >= date && storage_heater.end_date <= date
        total_capacity += storage_heater.kwp
      end
    end
    total_capacity
  end

  def storage_heater_on?(amr_data, date, halfhour_index, baseload_kwh)
    if @storage_heater_config.storage_heater_end_time_hh(date) > @storage_heater_config.storage_heater_start_time_hh(date)
      # when storage heater starts and ends in the same day
      halfhour_index >= @storage_heater_config.storage_heater_start_time_hh(date) &&
      halfhour_index <= @storage_heater_config.storage_heater_end_time_hh(date) &&
      amr_data.kwh(date, halfhour_index) > baseload_kwh * 1.5
    else
      # when storage heater starts before midnight
      ( halfhour_index >= @storage_heater_config.storage_heater_start_time_hh(date) ||
        halfhour_index <= @storage_heater_config.storage_heater_end_time_hh(date) ) &&
        amr_data.kwh(date, halfhour_index) > baseload_kwh * 1.5
    end
  end

  class StorageHeaterConfiguration
    MIN_DEFAULT_START_DATE = Date.new(2009, 1, 1)
    MAX_DEFAULT_END_DATE   = Date.new(2050, 1, 1)

    def initialize(meter_attributes_config)
      @config_by_date_range = {} # date_range = config
      parse_meter_attributes_configuration(meter_attributes_config)
    end

    def in_operation?(date)
      !config_for_date(date).empty?
    end

    def storage_heater_start_time_hh(date)
      @start_time_for_date ||= {}
      @start_time_for_date[date] ||= fractional_hh_from_time(config_for_date(date)[:charge_start_time])
    end

    def storage_heater_end_time_hh(date)
      @end_time_for_date ||= {}
      @end_time_for_date[date] ||= fractional_hh_from_time(config_for_date(date)[:charge_end_time])
    end

    private

    def fractional_hh_from_time(t)
      @fractional_hh_from_time ||= {}
      @fractional_hh_from_time[t] ||= t.to_halfhour_index
    end

    def config_for_date(date)
      @config_for_date ||= {}
      @config_for_date[date] ||= find_config_for_date(date)
    end

    def find_config_for_date(date)
      config_in_date_range = @config_by_date_range.select { |date_range, config| date >= date_range.first && date <= date_range.last }
      raise OverlappingStorageHeaterTimeConfigs, "Overlapping storage heater meter attribute time configs for #{date}" if config_in_date_range.length > 1
      config_in_date_range.empty? ? {} : config_in_date_range.values.first
    end

    def parse_meter_attributes_configuration(meter_attributes_config)
      # puts "Storage heater attributes are #{meter_attributes_config}"
      # ap(meter_attributes_config)
      if meter_attributes_config.nil?
        @config_by_date_range.merge!(parse_meter_attributes_configuration_for_period(nil))
      elsif meter_attributes_config.is_a?(Array)
        meter_attributes_config.each do |period_config|
          @config_by_date_range.merge!(parse_meter_attributes_configuration_for_period(period_config))
        end
      elsif meter_attributes_config.is_a?(Hash)
        @config_by_date_range.merge!(parse_meter_attributes_configuration_for_period(meter_attributes_config))
      else
        raise EnergySparksMeterSpecification.new('Unexpected meter attributes for storage heater, expecting array of hashes or hash')
      end
    end

    def parse_meter_attributes_configuration_for_period(period_config)
      start_date = (!period_config.nil? && period_config.key?(:start_date)) ? period_config[:start_date] : MIN_DEFAULT_START_DATE
      end_date   = (!period_config.nil? && period_config.key?(:end_date) )  ? period_config[:end_date]   : MAX_DEFAULT_END_DATE
      {
        start_date..end_date => period_config
        # TODO (PH 20Mar2019) sort out unpacking the meter config
      }
    end
  end
end
