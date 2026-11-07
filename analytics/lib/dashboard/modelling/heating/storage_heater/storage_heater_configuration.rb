require_relative '../storage_heater'

class StorageHeater
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
      config_in_date_range = @config_by_date_range.select do |date_range, config|
        date >= date_range.first && date <= date_range.last
      end
      if config_in_date_range.length > 1
        raise OverlappingStorageHeaterTimeConfigs,
              "Overlapping storage heater meter attribute time configs for #{date}"
      end

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
      start_date = !period_config.nil? && period_config.key?(:start_date) ? period_config[:start_date] : MIN_DEFAULT_START_DATE
      end_date   = !period_config.nil? && period_config.key?(:end_date) ? period_config[:end_date] : MAX_DEFAULT_END_DATE
      {
        start_date..end_date => period_config
        # TODO: (PH 20Mar2019) sort out unpacking the meter config
      }
    end
  end
end
