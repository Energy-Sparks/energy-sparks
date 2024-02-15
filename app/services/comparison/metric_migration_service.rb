module Comparison
  # Populate the MetricType model based on the definitions in the analytics
  class MetricMigrationService
    def migrate
      AlertType.enabled.each do |alert_type|
        create_metrics(alert_type) if alert_type.benchmark_variables.present?
      end
      true
    rescue => e
      puts e
      puts e.backtrace
      false
    end

    def key_for_metric(alert_type, key)
      if key.to_sym == :rating
        "#{alert_type.class_name.downcase}_rating".to_sym
      else
        key.to_sym
      end
    end

    # Maps the units defined by the alert classes to what we will be storing
    # in the database
    def units_for_metric_type(unit)
      # fallback if not declared by analytics
      return :float if unit.nil?
      return :boolean if unit == TrueClass
      # String => :string, Integer => :integer
      return unit.to_s.downcase.to_sym if unit.is_a?(Class)
      # { kw: :electricity}
      return unit.keys.first if unit.is_a?(Hash)
      # 00:30
      return :string if unit == :timeofday
      return :string if unit == :school_type
      return :integer if [:days, :years].include?(unit)
      return :float if [:morning_start_time, :optimum_start_sensitivity, :r2, :opt_start_standard_deviation, :m2, :pupils, :co2t, :kwp].include?(unit)
      # Let everything else pass through
      unit.to_sym
    end

    def fuel_type_for_metric_type(key, definition, alert_type)
      return alert_type.fuel_type.to_sym if alert_type.fuel_type.present?

      if definition[:units].is_a?(Hash)
        # { kwh: :electricity }
        return definition[:units].values[0]
      end

      # other keys, e.g. from AlertEnergyAnnualVersusBenchmark include
      # the fuel type in the name
      case key.to_s
      when /electricity/
        :electricity
      when /gas/
        :gas
      when /storage_heater/
        :storage_heater
      when /solar/
        :solar_pv
      else
        :multiple
      end
    end

    private

    def create_metrics(alert_type)
      alert_type.class_from_name.benchmark_template_variables.each do |key, definition|
        next if ignore?(key)
        MetricType.find_or_create_by!(
          key: key_for_metric(alert_type, key),
          fuel_type: fuel_type_for_metric_type(key, definition, alert_type)
        ) do |new_record|
          new_record.units = units_for_metric_type(definition[:units])
          # these will later need to be reviewed and replaced
          new_record.label = definition[:description]
          new_record.description = "Migrated from #{alert_type.class_name} (#{definition[:benchmark_code]})"
        end
      end
    end

    def ignore?(key)
      [:activation_date, :floor_area, :pupils, :school_name, :school_area, :school_type, :school_type_name, :urn, :degree_days_15_5C_domestic].include?(key)
    end
  end
end
