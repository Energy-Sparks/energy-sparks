require_relative './alert_arbitrary_period_comparison_mixin.rb'
require_relative './alert_period_comparison_gas_mixin.rb'
require_relative './alert_period_comparison_temperature_adjustment_mixin.rb'

#===================================================================================================
# Power up layer down day November 2022
module AlertLayerUpPowerdown11November2022BasicConfigMixIn
  def basic_configuration
    {
      name:                   'Layer up power down day 11 November 2022',
      max_days_out_of_date:   365,
      enough_days_data:       1,
      current_period:         Date.new(2022, 11, 11)..Date.new(2022, 11, 11),
      previous_period:        Date.new(2021, 11, 12)..Date.new(2021, 11, 12)
    }
  end
end

class AlertLayerUpPowerdown11November2022ElectricityComparison < AlertArbitraryPeriodComparisonElectricityBase
  include ArbitraryPeriodComparisonMixIn
  include AlertLayerUpPowerdown11November2022BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :layerup_powerdown_11_november_2022_electricity_comparison_alert
    }.merge(basic_configuration)
  end
end

class AlertLayerUpPowerdown11November2022GasComparison < AlertArbitraryPeriodComparisonGasBase
  include ArbitraryPeriodComparisonMixIn
  include AlertLayerUpPowerdown11November2022BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :layerup_powerdown_11_november_2022_gas_comparison_alert
    }.merge(basic_configuration)
  end

  def calculate(asof_date)
    super(asof_date)
  end
end

class AlertLayerUpPowerdown11November2022StorageHeaterComparison < AlertArbitraryPeriodComparisonStorageHeaterBase
  include ArbitraryPeriodComparisonMixIn
  include AlertLayerUpPowerdown11November2022BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :layerup_powerdown_11_november_2022_storage_heater_comparison_alert
    }.merge(basic_configuration)
  end
end

#===================================================================================================
# Autumn term 2021-2022 comparison
module AlertAutumnTerm20212022ComparisonMixIn
  def basic_configuration
    {
      name:                   'Autumn term 2021 versus 2022 energy use comparison',
      max_days_out_of_date:   365,
      enough_days_data:       1,
      current_period:         Date.new(2022, 9, 5)..Date.new(2022, 12, 16),
      previous_period:        Date.new(2021, 9, 6)..Date.new(2021, 12, 17)
    }
  end
end

class AlertAutumnTerm20212022ElectricityComparison < AlertArbitraryPeriodComparisonElectricityBase
  include ArbitraryPeriodComparisonMixIn
  include AlertAutumnTerm20212022ComparisonMixIn

  def comparison_configuration
    {
      comparison_chart:       :autumn_term_2022_electricity_comparison_alert
    }.merge(basic_configuration)
  end
end

class AlertAutumnTerm20212022GasComparison < AlertArbitraryPeriodComparisonGasBase
  include ArbitraryPeriodComparisonMixIn
  include AlertAutumnTerm20212022ComparisonMixIn

  def comparison_configuration
    {
      comparison_chart:       :autumn_term_2022_gas_comparison_alert
    }.merge(basic_configuration)
  end
end

class AlertAutumnTerm20212022StorageHeaterComparison < AlertArbitraryPeriodComparisonStorageHeaterBase
  include ArbitraryPeriodComparisonMixIn
  include AlertAutumnTerm20212022ComparisonMixIn

  def comparison_configuration
    {
      comparison_chart:       :autumn_term_2022_storage_heater_comparison_alert
    }.merge(basic_configuration)
  end
end

#===================================================================================================
# September-November 2021-2022 comparison
module AlertSeptNov20212022ComparisonMixIn
  def basic_configuration
    {
      name:                   'Autumn term 2021 versus 2022 energy use comparison',
      max_days_out_of_date:   365,
      enough_days_data:       1,
      current_period:         Date.new(2022, 9, 1)..Date.new(2022, 11, 30),
      previous_period:        Date.new(2021, 9, 1)..Date.new(2021, 11, 30)
    }
  end
end

class AlertSeptNov20212022ElectricityComparison < AlertAutumnTerm20212022ElectricityComparison
end

class AlertSeptNov20212022GasComparison < AlertAutumnTerm20212022GasComparison
end

class AlertSeptNov20212022StorageHeaterComparison < AlertAutumnTerm20212022StorageHeaterComparison
end

module AlertEaster2023ShutdownConfigurationMixin
  def basic_configuration
    {
      name:                   'Easter shutdown 2023',
      max_days_out_of_date:   30,
      enough_days_data:       1,
      holiday_date:           Date.new(2023,4,7), #good friday
      school_weeks:           0
    }
  end
end

class AlertEaster2023ShutdownElectricityComparison < AlertArbitraryPeriodComparisonElectricityBase
  include ArbitraryPeriodComparisonMixIn #adds in helpers
  include HolidayShutdownComparisonMixin #adds in some additional helpers
  include AlertEaster2023ShutdownConfigurationMixin #mixin the configuration

  #Method to access the configuration
  def comparison_configuration
    basic_configuration
  end
end

class AlertEaster2023ShutdownGasComparison < AlertArbitraryPeriodComparisonGasBase
  include ArbitraryPeriodComparisonMixIn #adds in helpers
  include HolidayShutdownComparisonMixin #adds in some additional helpers
  include AlertEaster2023ShutdownConfigurationMixin #mixin the configuration

  #Method to access the configuration
  def comparison_configuration
    basic_configuration
  end
end

class AlertEaster2023ShutdownStorageHeaterComparison < AlertArbitraryPeriodComparisonStorageHeaterBase
  include ArbitraryPeriodComparisonMixIn #adds in helpers
  include HolidayShutdownComparisonMixin #adds in some additional helpers
  include AlertEaster2023ShutdownConfigurationMixin #mixin the configuration

  #Method to access the configuration
  def comparison_configuration
    basic_configuration
  end
end

#===================================================================================================
# Jan-August 2022-2023 comparison
module AlertJanAug20222023ComparisonMixIn
  def basic_configuration
    {
      name:                   'Jan-August 2022 energy use comparison',
      max_days_out_of_date:   365,
      enough_days_data:       242,
      current_period:         Date.new(2023, 1, 1)..Date.new(2023, 8, 31),
      previous_period:        Date.new(2022, 1, 1)..Date.new(2022, 8, 31)
    }
  end

  #Override to disable the default period normalisation and temperature compensation
  #applied to the previous period. Instead just return the consumption values
  #for the period, unchanged
  def normalised_period_data(_current_period, previous_period)
    meter_values_period(previous_period)
  end

  #Disable pupil and floor area adjustments between periods
  def pupil_floor_area_adjustment
    1.0
  end
end

class AlertJanAug20222023ElectricityComparison < AlertArbitraryPeriodComparisonElectricityBase
  include ArbitraryPeriodComparisonMixIn
  include AlertJanAug20222023ComparisonMixIn

  def comparison_configuration
    basic_configuration
  end

end

class AlertJanAug20222023GasComparison < AlertArbitraryPeriodComparisonGasBase
  include ArbitraryPeriodComparisonMixIn
  include AlertJanAug20222023ComparisonMixIn

  def comparison_configuration
    basic_configuration
  end
end

class AlertJanAug20222023StorageHeaterComparison < AlertArbitraryPeriodComparisonStorageHeaterBase
  include ArbitraryPeriodComparisonMixIn
  include AlertJanAug20222023ComparisonMixIn

  def comparison_configuration
    basic_configuration
  end
end

#===================================================================================================
# Power up layer down day November 2023
module AlertLayerUpPowerdownNovember2023BasicConfigMixIn
  def basic_configuration
    {
      name:                   'Layer up power down day 24 November 2023',
      max_days_out_of_date:   365,
      enough_days_data:       1,
      current_period:         Date.new(2023, 11, 24)..Date.new(2023, 11, 24),
      previous_period:        Date.new(2023, 11, 17)..Date.new(2023, 11, 17)
    }
  end
end

class AlertLayerUpPowerdownNovember2023ElectricityComparison < AlertArbitraryPeriodComparisonElectricityBase
  include ArbitraryPeriodComparisonMixIn
  include AlertLayerUpPowerdownNovember2023BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :layerup_powerdown_november_2023_electricity_comparison_alert
    }.merge(basic_configuration)
  end
end

class AlertLayerUpPowerdownNovember2023GasComparison < AlertArbitraryPeriodComparisonGasBase
  include ArbitraryPeriodComparisonMixIn
  include AlertLayerUpPowerdownNovember2023BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :layerup_powerdown_november_2023_gas_comparison_alert
    }.merge(basic_configuration)
  end
end

class AlertLayerUpPowerdownNovember2023StorageHeaterComparison < AlertArbitraryPeriodComparisonStorageHeaterBase
  include ArbitraryPeriodComparisonMixIn
  include AlertLayerUpPowerdownNovember2023BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :layerup_powerdown_november_2023_storage_heater_comparison_alert
    }.merge(basic_configuration)
  end
end

#===================================================================================================
# Feb/March 2024 competition
module AlertHeatSaver2024BasicConfigMixIn
  def basic_configuration
    {
      name:                   'Winter Heat Saver Feb-March 2024',
      max_days_out_of_date:   365,
      enough_days_data:       1,
      current_period:         Date.new(2024, 2, 25)..Date.new(2024, 3, 23),
      previous_period:        Date.new(2023, 2, 26)..Date.new(2023, 3, 25),
    }
  end
end

class AlertHeatSaver2024ElectricityComparison < AlertArbitraryPeriodComparisonElectricityBase
  include ArbitraryPeriodComparisonMixIn
  include AlertHeatSaver2024BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :heat_saver_march_2024_electricity_comparison_alert
    }.merge(basic_configuration)
  end
end

class AlertHeatSaver2024GasComparison < AlertArbitraryPeriodComparisonGasBase
  include ArbitraryPeriodComparisonMixIn
  include AlertHeatSaver2024BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :heat_saver_march_2024_gas_comparison_alert
    }.merge(basic_configuration)
  end
end

class AlertHeatSaver2024StorageHeaterComparison < AlertArbitraryPeriodComparisonStorageHeaterBase
  include ArbitraryPeriodComparisonMixIn
  include AlertHeatSaver2024BasicConfigMixIn

  def comparison_configuration
    {
      comparison_chart:       :heat_saver_march_2024_storage_heater_comparison_alert
    }.merge(basic_configuration)
  end
end
