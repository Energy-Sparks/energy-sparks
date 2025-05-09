require_relative './meter_attribute_types'
require_relative './open_close_time.rb'
class MeterAttributes

  class AutoInsertMissingReadings < MeterAttributeTypes::AttributeBase

    id :meter_corrections_auto_insert_missing_readings
    key :auto_insert_missing_readings
    aggregate_over :meter_corrections

    name 'Meter correction > Auto insert missing readings'
    description 'A meter correction that uses past data to fill in readings that are missing. Useful for schools with flaky meters.'


    structure MeterAttributeTypes::Hash.define(
      structure: {
        type: MeterAttributeTypes::Symbol.define(allowed_values: [:weekends], required: true)
      }
    )
  end

  class NoHeatingInSummerSetMissingToZero < MeterAttributeTypes::AttributeBase

    id :meter_corrections_no_heating_in_summer_set_missing_to_zero
    key :no_heating_in_summer_set_missing_to_zero
    aggregate_over :meter_corrections
    name 'Meter correction > No heating in summer set missing to zero'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_toy: MeterAttributeTypes::TimeOfYear.define(required: true),
        end_toy: MeterAttributeTypes::TimeOfYear.define(required: true)
      }
    )
  end

  class RescaleAmrData < MeterAttributeTypes::AttributeBase
    id :meter_corrections_rescale_amr_data
    key :rescale_amr_data
    aggregate_over :meter_corrections
    name 'Meter correction > Rescale AMR data'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: true),
        end_date:   MeterAttributeTypes::Date.define(required: true),
        scale:      MeterAttributeTypes::Float.define(required: true)
      }
    )
  end

  class SetMissingDataToZero < MeterAttributeTypes::AttributeBase
    id :meter_corrections_set_missing_data_to_zero
    key :set_missing_data_to_zero
    aggregate_over :meter_corrections
    name 'Meter correction > Set missing data to zero'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date:               MeterAttributeTypes::Date.define(required: false),
        end_date:                 MeterAttributeTypes::Date.define(required: false),
        zero_up_until_yesterday:  MeterAttributeTypes::Boolean.define(required: false, hint: 'if set true will set zero values up until yesterday, else up until the last meter reading')
      }
    )
  end

  class OverrideBadReadings < MeterAttributeTypes::AttributeBase
    id :meter_corrections_override_bad_readings
    key :override_bad_readings
    aggregate_over :meter_corrections
    name 'Meter correction > Substitute bad readings'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: true),
        end_date:   MeterAttributeTypes::Date.define(required: true)
      }
    )
  end

  class OverrideZeroDays < MeterAttributeTypes::AttributeBase
    id  :override_zero_days_electricity_readings
    key :override_zero_days_electricity_readings
    aggregate_over :meter_corrections
    name 'Meter correction > Override All Zero Days'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date:   MeterAttributeTypes::Date.define,
        override:   MeterAttributeTypes::Symbol.define(allowed_values: [:on, :intelligent_solar, :off])
      }
    )
  end

  class ExtendMeterReadingsForSubstitution < MeterAttributeTypes::AttributeBase
    id :meter_corrections_extend_meter_readings_for_substitution
    key :extend_meter_readings_for_substitution
    aggregate_over :meter_corrections
    name 'Meter correction > Extend meter reading range for substitutions'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: false),
        end_date:   MeterAttributeTypes::Date.define(required: false)
      }
    )
  end

  class SetBadDataToZero < MeterAttributeTypes::AttributeBase
    id :meter_corrections_set_bad_data_to_zero
    key :set_bad_data_to_zero
    aggregate_over :meter_corrections
    name 'Meter correction > Set bad data to zero'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: true),
        end_date:   MeterAttributeTypes::Date.define(required: true)
      }
    )
  end

  class ReadingsStartDate < MeterAttributeTypes::AttributeBase
    id :meter_corrections_readings_start_date
    key :readings_start_date
    aggregate_over :meter_corrections
    name 'Meter correction > Readings start date'
    structure MeterAttributeTypes::Date.define(required: true)
  end

  class ReadingsEndDate < MeterAttributeTypes::AttributeBase
    id :meter_corrections_readings_end_date
    key :readings_end_date
    aggregate_over :meter_corrections
    name 'Meter correction > Readings end date'
    structure MeterAttributeTypes::Date.define(required: true)
  end

  class MeterCorrectionSwitch < MeterAttributeTypes::AttributeBase
    id :meter_corrections_switch
    aggregate_over :meter_corrections
    name 'Meter correction > Switch'
    structure MeterAttributeTypes::Symbol.define(required: true, allowed_values: [:set_all_missing_to_zero, :correct_zero_partial_data])
  end

  class OverrideNightToZero < MeterAttributeTypes::AttributeBase
    id :meter_corrections_override_night_to_zero
    key :override_night_to_zero
    aggregate_over :meter_corrections
    name 'Meter correction > Set night time readings to zero'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date: MeterAttributeTypes::Date.define
      }
    )
  end

  class PartialMeterFloorAreaPupilNumberOverride < MeterAttributeTypes::AttributeBase
    id :partial_meter_coverage
    key :partial_meter_coverage
    aggregate_over :partial_meter_coverage
    name 'Schools > Override percent of floor area or pupil numbers covered by meter'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date:   MeterAttributeTypes::Date.define,
        percent_floor_area:      MeterAttributeTypes::Float.define(required: true),
        percent_pupil_numbers:   MeterAttributeTypes::Float.define(required: true)
      }
    )
  end


  def self.time_of_day_range
    MeterAttributeTypes::Hash.define(
      required: false,
      structure: {
        day_of_week:  MeterAttributeTypes::Symbol.define(required: true, allowed_values: OpenCloseTime.day_of_week_types),
        from:         MeterAttributeTypes::TimeOfDay.define(required: true),
        to:           MeterAttributeTypes::TimeOfDay.define(required: true)
      }
    )
  end

  class OpenCloseTimesAttributes < MeterAttributeTypes::AttributeBase
    analytics_internal true
    id :open_close_times
    aggregate_over :open_close_times
    name 'School and community function opening and closing times'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        type:             MeterAttributeTypes::Symbol.define(required: true, allowed_values: OpenCloseTime.user_configurable_community_use_types.keys),
        holiday_calendar: MeterAttributeTypes::Symbol.define(required: true, allowed_values: OpenCloseTime.calendar_types),
        start_date:       MeterAttributeTypes::Date.define,
        end_date:         MeterAttributeTypes::Date.define,
        fuel_types:       MeterAttributeTypes::Symbol.define(required: true, allowed_values: OpenCloseTime.fuel_type_choices),
        time0:            MeterAttributes.time_of_day_range,
        time1:            MeterAttributes.time_of_day_range,
        time2:            MeterAttributes.time_of_day_range,
        time3:            MeterAttributes.time_of_day_range,

        fixed_power_kw:   MeterAttributeTypes::Float.define(min: 0.0, hint: 'flood lighting only')
      }
    )
  end

  class StorageHeaterPartialMeterFloorAreaPupilNumberOverride < MeterAttributeTypes::AttributeBase
    id :storage_heater_partial_meter_coverage
    key :storage_heater_partial_meter_coverage
    aggregate_over :storage_heater_partial_meter_coverage
    name 'Storage Heaters > Override percent of floor area or pupil numbers covered by storage heaters'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date:   MeterAttributeTypes::Date.define,
        percent_floor_area:      MeterAttributeTypes::Float.define(required: true),
        percent_pupil_numbers:   MeterAttributeTypes::Float.define(required: true)
      }
    )
  end

  class FloorAreaPupilNumbersChangeOverTimeOverride < MeterAttributeTypes::AttributeBase
    id :floor_area_pupil_numbers
    aggregate_over :floor_area_pupil_numbers
    name 'Schools > Changing floor area and pupil numbers over time'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date:       MeterAttributeTypes::Date.define,
        end_date:         MeterAttributeTypes::Date.define,
        floor_area:       MeterAttributeTypes::Float.define(required: true),
        number_of_pupils: MeterAttributeTypes::Float.define(required: true)
      }
    )
  end

  class PartialMeterFloorAreaPupilNumberDateRangeOverride < MeterAttributeTypes::AttributeBase
    id :partial_meter_coverage_date_range
    key :partial_meter_coverage_date_range
    aggregate_over :meter_corrections
    name 'Schools > Override percent of floor area or pupil numbers covered by meter - with date ranges'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: true),
        end_date:   MeterAttributeTypes::Date.define(required: true),
        percent_floor_area:      MeterAttributeTypes::Float.define(required: true),
        percent_pupil_numbers:   MeterAttributeTypes::Float.define(required: true)
      }
    )
  end

  class HeatingModel < MeterAttributeTypes::AttributeBase

    id :heating_model
    key :heating_model
    name 'Heating > Heating model'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        max_summer_daily_heating_kwh: MeterAttributeTypes::Integer.define(required: true),
        fitting: MeterAttributeTypes::Hash.define(
          required: false,
          structure: {
            fit_model_start_date:           MeterAttributeTypes::Date.define,
            fit_model_end_date:             MeterAttributeTypes::Date.define,
            expiry_date_of_override:        MeterAttributeTypes::Date.define,
            use_dates_for_model_validation: MeterAttributeTypes::Boolean.define
          }
        )
      }
    )
  end

  class TargetingAndTrackingProfilesMaximumRetries < MeterAttributeTypes::AttributeBase
    id :targeting_and_tracking_profiles_maximum_retries
    key :targeting_and_tracking_profiles_maximum_retries

    name 'Targets > Targets profile substitution limit (temperature compensation)'
    description 'Used to override targeting and tracking system maximum automatic nil profiles substituted in the event more are required - should only be added after review by an ebergy analyst'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        number_of_retries: MeterAttributeTypes::Integer.define(required: true)
      }
    )
  end

  class HeatingNonHeatingDayFixedkWh < MeterAttributeTypes::AttributeBase
    id  :heating_non_heating_day_fixed_kwh_separation
    key :heating_non_heating_day_fixed_kwh_separation
    name 'Heating > Heating/Non-Heating Separation Model Fixed Separation in kWh'
    structure MeterAttributeTypes::Float.define(required: true, hint: 'kwh per day')
  end

  class HeatingNonHeatingDaySeparationModelOverride < MeterAttributeTypes::AttributeBase
    id  :heating_non_heating_day_separation_model_override
    key :heating_non_heating_day_separation_model_override
    name 'Heating > Heating/Non-Heating Separation Model Override'

    structure MeterAttributeTypes::Symbol.define(required: true, allowed_values: [:fixed_single_value_temperature_sensitive_regression_model, :temperature_sensitive_regression_model, :temperature_sensitive_regression_model_covid_tolerant, :no_idea, :either, :not_enough_data])
  end

  class AggregationSwitch < MeterAttributeTypes::AttributeBase

    id :aggregation_switch
    aggregate_over :aggregation
    name 'Meter > Data presentation'

    structure MeterAttributeTypes::Symbol.define(required: true, allowed_values: [:ignore_start_date, :deprecated_include_but_ignore_start_date, :deprecated_include_but_ignore_end_date])
  end

  class FunctionSwitch < MeterAttributeTypes::AttributeBase

    id :function_switch
    aggregate_over :function
    name 'Meter > Energy Use'

    structure MeterAttributeTypes::Symbol.define(required: true, allowed_values: [:heating_only, :kitchen_only, :hotwater_only])
  end

  class SolarPV < MeterAttributeTypes::AttributeBase

    id :solar_pv
    aggregate_over :solar_pv
    name 'Solar > Solar PV'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date:         MeterAttributeTypes::Date.define,
        end_date:           MeterAttributeTypes::Date.define,
        kwp:                MeterAttributeTypes::Float.define,
        orientation:        MeterAttributeTypes::Integer.define(hint: 'in degrees'),
        tilt:               MeterAttributeTypes::Integer.define,
        shading:            MeterAttributeTypes::Integer.define,
        fit_£_per_kwh:      MeterAttributeTypes::Float.define,
        maximum_export_level_kw: MeterAttributeTypes::Float.define
      }
    )
  end

  class SolarPVOverrides < SolarPV

    id :solar_pv_override
    aggregate_over :solar_pv_override
    name 'Solar > Override bad metered solar pv data'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date:             MeterAttributeTypes::Date.define,
        end_date:               MeterAttributeTypes::Date.define,
        kwp:                    MeterAttributeTypes::Float.define,
        orientation:            MeterAttributeTypes::Integer.define(hint: 'in degrees'),
        tilt:                   MeterAttributeTypes::Integer.define,
        shading:                MeterAttributeTypes::Integer.define,
        fit_£_per_kwh:          MeterAttributeTypes::Float.define,
        override_generation:    MeterAttributeTypes::Boolean.define(required: false, hint: 'Check this to override generation data'),
        override_export:        MeterAttributeTypes::Boolean.define(required: false, hint: 'Check this to override export data'),
        override_self_consume:  MeterAttributeTypes::Boolean.define(required: false, hint: 'Check this to override self consumption data')
      }
    )

    # NB uses inherited attributes
  end

  class SolarPVMeterMapping < MeterAttributeTypes::AttributeBase

    id                  :solar_pv_mpan_meter_mapping
    aggregate_over      :solar_pv_mpan_meter_mapping
    name                'Solar > Solar PV MPAN Meter mapping'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date:         MeterAttributeTypes::Date.define(required: true),
        end_date:           MeterAttributeTypes::Date.define,
        export_mpan:        MeterAttributeTypes::String.define,
        production_mpan:    MeterAttributeTypes::String.define,
        self_consume_mpan:  MeterAttributeTypes::String.define(hint: 'currently unsupported'),
        production_mpan2:   MeterAttributeTypes::String.define(hint: 'for 2nd generation meter'),
        production_mpan3:   MeterAttributeTypes::String.define(hint: 'for 3rd generation meter'),
        production_mpan4:   MeterAttributeTypes::String.define(hint: 'for 4th generation meter'),
        production_mpan5:   MeterAttributeTypes::String.define(hint: 'for 5th generation meter')
      }
    )
  end

  class LowCarbonHub < MeterAttributeTypes::AttributeBase

    id :low_carbon_hub_meter_id
    key :low_carbon_hub_meter_id
    name 'Solar > Low carbon hub meter ID'

    structure MeterAttributeTypes::Integer.define(required: true, min: 0)

  end

  class StorageHeaters < MeterAttributeTypes::AttributeBase
    id :storage_heaters
    aggregate_over :storage_heaters
    name 'Storage heaters > Storage heater configuration'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date:         MeterAttributeTypes::Date.define,
        end_date:           MeterAttributeTypes::Date.define,
        power_kw:           MeterAttributeTypes::Float.define,
        charge_start_time:  MeterAttributeTypes::TimeOfDay.define,
        charge_end_time:    MeterAttributeTypes::TimeOfDay.define
      }
    )
  end

  class TargetingAndTracking < MeterAttributeTypes::AttributeBase
    analytics_internal true
    id :targeting_and_tracking
    aggregate_over :targeting_and_tracking
    name 'Targets > Setting of Targets for Targeting and Tracking'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(hint: 'start of year setting target for (versus previous year)'),
        target:     MeterAttributeTypes::Float.define(hint: 'e.g. 0.95 = a 5% reduction over previous year'),
      }
    )
  end

  class EstimatedPeriodConsumption < MeterAttributeTypes::AttributeBase
    analytics_internal true
    id :estimated_period_consumption
    aggregate_over :estimated_period_consumption
    name 'Targets > Estimated consumption for period'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: true),
        end_date:   MeterAttributeTypes::Date.define(required: true),
        kwh:        MeterAttributeTypes::Float.define(required: true)
      }
    )
  end

  class BackdateTariff < MeterAttributeTypes::AttributeBase

    id :backdate_tariff
    key :backdate_tariff
    name 'Tariffs > Backdate DCC tariff'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        days: MeterAttributeTypes::Integer.define(required: true, hint: 'by default backdates up to 30 days, if you set to 0 then wont backdate')
      }
    )
  end

  def self.default_tariff_rates
    {
      standing_charge: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(required: true, allowed_values: [:day, :month, :quarter]),
          rate: MeterAttributeTypes::Float.define(required: true)
        }
      ),
      climate_change_levy: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:kwh]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      renewable_energy_obligation: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:kwh]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      feed_in_tariff_levy: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:kwh]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      agreed_capacity: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:day, :month, :quarter]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      agreed_availability_charge: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:kva]),
          rate: MeterAttributeTypes::Float.define(hint: 'enter £ value per KVA, and units KVA in the separate Agreed Supply Capacity field')
        }
      ),
      excess_availability_charge: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:kva]),
          rate: MeterAttributeTypes::Float.define(hint: 'enter £ value per KVA, and units KVA in the separate Agreed Supply Capacity field')
        }
      ),
      settlement_agency_fee: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:day, :month, :quarter]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      reactive_power_charge: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:kva]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      data_collection_dcda_agent_charge: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:day, :month, :quarter]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      nhh_automatic_meter_reading_charge: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:day, :month, :quarter]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      half_hourly_data_charge: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:day, :month, :quarter]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      fixed_charge: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:day, :month, :quarter]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      nhh_metering_agent_charge: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:kwh, :day, :month, :quarter], hint: 'divide the total charge by the number of days in the month'),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      meter_asset_provider_charge: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:day, :month, :quarter]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      site_fee: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:day, :month, :quarter]),
          rate: MeterAttributeTypes::Float.define
        }
      ),
      other: MeterAttributeTypes::Hash.define(
        structure: {
          per:  MeterAttributeTypes::Symbol.define(allowed_values: [:kwh, :day, :month, :quarter]),
          rate: MeterAttributeTypes::Float.define
        }
      )
    }
  end

  def self.default_flat_rate
    MeterAttributeTypes::Hash.define(
      required: false,
      structure: {
        per:  MeterAttributeTypes::Symbol.define(required: true, allowed_values: [:kwh]),
        rate: MeterAttributeTypes::Float.define(required: true)
      }
    )
  end

  def self.default_rate
    MeterAttributeTypes::Hash.define(
      required: false,
      structure: {
        per:  MeterAttributeTypes::Symbol.define(required: true, allowed_values: [:kwh]),
        rate: MeterAttributeTypes::Float.define(required: true),
        from: MeterAttributeTypes::TimeOfDay30mins.define(required: true),
        to:   MeterAttributeTypes::TimeOfDay30mins.define(required: true),
      }
    )
  end

  def self.default_tiered_rate_definition
    MeterAttributeTypes::Hash.define(
      required: false,
      structure: {
        low_threshold:  MeterAttributeTypes::Float.define(required: true),
        high_threshold: MeterAttributeTypes::Float.define(required: true),
        rate:           MeterAttributeTypes::Float.define(required: true)
      }
    )
  end

  def self.default_tiered_rate
    MeterAttributeTypes::Hash.define(
      required: false,
      structure: {
        per:  MeterAttributeTypes::Symbol.define(required: true, allowed_values: [:kwh]),
        from: MeterAttributeTypes::TimeOfDay30mins.define(required: true),
        to:   MeterAttributeTypes::TimeOfDay30mins.define(required: true),
        tier0: default_tiered_rate_definition,
        tier1: default_tiered_rate_definition,
        tier2: default_tiered_rate_definition,
        tier3: default_tiered_rate_definition
      }
    )
  end

  def self.generic_accounting_tariff
    MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date:   MeterAttributeTypes::Date.define,
        source:     MeterAttributeTypes::Symbol.define(required: false, allowed_values: [:dcc, :manually_entered]),
        name:       MeterAttributeTypes::String.define,
        type:       MeterAttributeTypes::Symbol.define(required: true, allowed_values: %i[flat differential differential_tiered]),
        sub_type:   MeterAttributeTypes::Symbol.define(required: false, allowed_values: [:weekday_weekend]),
        vat:        MeterAttributeTypes::Symbol.define(required: true, allowed_values: ['0%'.to_sym, '5%'.to_sym, '20%'.to_sym]),
        # default:    MeterAttributeTypes::Boolean.define(hint: 'Enable for group/site-wide tariffs where tariff is used as a fallback'),
        rates:      MeterAttributeTypes::Hash.define(
          required: false,
          structure: {
            flat_rate:          MeterAttributes.default_flat_rate,
            commodity_rate:     MeterAttributes.default_flat_rate,
            non_commodity_rate: MeterAttributes.default_flat_rate,

            # enumerated hash keys as not sure front end can copy with an array?
            rate0:        MeterAttributes.default_rate,
            rate1:        MeterAttributes.default_rate,
            rate2:        MeterAttributes.default_rate,
            rate3:        MeterAttributes.default_rate,

            tiered_rate0: MeterAttributes.default_tiered_rate,
            tiered_rate1: MeterAttributes.default_tiered_rate,
            tiered_rate2: MeterAttributes.default_tiered_rate,
            tiered_rate3: MeterAttributes.default_tiered_rate,

            duos_red:     MeterAttributeTypes::Float.define,
            duos_amber:   MeterAttributeTypes::Float.define,
            duos_green:   MeterAttributeTypes::Float.define,

            tnuos:        MeterAttributeTypes::Boolean.define(hint: 'tick if transmission network use of system appears on bill'),

            weekday:     MeterAttributeTypes::Boolean.define,
            weekend:     MeterAttributeTypes::Boolean.define,
          }.merge(MeterAttributes.default_tariff_rates)
        ),
        asc_limit_kw:           MeterAttributeTypes::Float.define,
        climate_change_levy:    MeterAttributeTypes::Boolean.define,
        tariff_holder:   MeterAttributeTypes::Symbol.define(required: false, allowed_values: [:meter, :school, :school_group, :site_settings]),
        created_at:      MeterAttributeTypes::DateTime.define(required: false)
      }
    )
  end

  class AccountingGenericTariff < MeterAttributeTypes::AttributeBase
    analytics_internal true
    id :accounting_tariff_generic
    aggregate_over :accounting_tariff_generic
    name 'Tariffs > Generic Accounting tariff'

    structure MeterAttributes.generic_accounting_tariff
  end

  def self.all(filter: false)
    constants.inject({}) do |collection, constant_name|
      constant = const_get(constant_name)
      collection[constant.attribute_id] = constant unless (filter && constant.internal?)
      collection
    end
  end

end
