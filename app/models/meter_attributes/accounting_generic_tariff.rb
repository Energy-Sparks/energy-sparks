# frozen_string_literal: true

module MeterAttributes
  class AccountingGenericTariff < MeterAttributeTypes::AttributeBase # rubocop:todo Metrics/ClassLength
    analytics_internal true
    id :accounting_tariff_generic
    aggregate_over :accounting_tariff_generic
    name 'Tariffs > Generic Accounting tariff'

    def self.default_tariff_rates # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      {
        standing_charge: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(required: true, allowed_values: %i[day month quarter]),
            rate: MeterAttributeTypes::Float.define(required: true)
          }
        ),
        climate_change_levy: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: [:kwh]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        renewable_energy_obligation: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: [:kwh]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        feed_in_tariff_levy: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: [:kwh]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        agreed_capacity: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: %i[day month quarter]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        agreed_availability_charge: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: [:kva]),
            rate: MeterAttributeTypes::Float.define(
              hint: 'enter £ value per KVA, and units KVA in the separate Agreed Supply Capacity field'
            )
          }
        ),
        excess_availability_charge: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: [:kva]),
            rate: MeterAttributeTypes::Float.define(
              hint: 'enter £ value per KVA, and units KVA in the separate Agreed Supply Capacity field'
            )
          }
        ),
        settlement_agency_fee: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: %i[day month quarter]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        reactive_power_charge: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: [:kva]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        data_collection_dcda_agent_charge: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: %i[day month quarter]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        nhh_automatic_meter_reading_charge: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: %i[day month quarter]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        half_hourly_data_charge: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: %i[day month quarter]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        fixed_charge: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: %i[day month quarter]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        nhh_metering_agent_charge: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: %i[kwh day month quarter],
                                                    hint: 'divide the total charge by the number of days in the month'),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        meter_asset_provider_charge: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: %i[day month quarter]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        site_fee: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: %i[day month quarter]),
            rate: MeterAttributeTypes::Float.define
          }
        ),
        other: MeterAttributeTypes::Hash.define(
          structure: {
            per: MeterAttributeTypes::Symbol.define(allowed_values: %i[kwh day month quarter]),
            rate: MeterAttributeTypes::Float.define
          }
        )
      }
    end

    def self.default_flat_rate
      MeterAttributeTypes::Hash.define(
        required: false,
        structure: {
          per: MeterAttributeTypes::Symbol.define(required: true, allowed_values: [:kwh]),
          rate: MeterAttributeTypes::Float.define(required: true)
        }
      )
    end

    def self.default_rate
      MeterAttributeTypes::Hash.define(
        required: false,
        structure: {
          per: MeterAttributeTypes::Symbol.define(required: true, allowed_values: [:kwh]),
          rate: MeterAttributeTypes::Float.define(required: true),
          from: MeterAttributeTypes::TimeOfDay30mins.define(required: true),
          to: MeterAttributeTypes::TimeOfDay30mins.define(required: true)
        }
      )
    end

    def self.default_tiered_rate_definition
      MeterAttributeTypes::Hash.define(
        required: false,
        structure: {
          low_threshold: MeterAttributeTypes::Float.define(required: true),
          high_threshold: MeterAttributeTypes::Float.define(required: true),
          rate: MeterAttributeTypes::Float.define(required: true)
        }
      )
    end

    def self.default_tiered_rate
      MeterAttributeTypes::Hash.define(
        required: false,
        structure: {
          per: MeterAttributeTypes::Symbol.define(required: true, allowed_values: [:kwh]),
          from: MeterAttributeTypes::TimeOfDay30mins.define(required: true),
          to: MeterAttributeTypes::TimeOfDay30mins.define(required: true),
          tier0: default_tiered_rate_definition,
          tier1: default_tiered_rate_definition,
          tier2: default_tiered_rate_definition,
          tier3: default_tiered_rate_definition
        }
      )
    end

    def self.generic_accounting_tariff # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      MeterAttributeTypes::Hash.define(
        structure: {
          start_date: MeterAttributeTypes::Date.define,
          end_date: MeterAttributeTypes::Date.define,
          source: MeterAttributeTypes::Symbol.define(required: false, allowed_values: %i[dcc manually_entered]),
          name: MeterAttributeTypes::String.define,
          type: MeterAttributeTypes::Symbol.define(required: true,
                                                   allowed_values: %i[
                                                     flat differential differential_tiered
                                                   ]),
          sub_type: MeterAttributeTypes::Symbol.define(required: false, allowed_values: [:weekday_weekend]),
          vat: MeterAttributeTypes::Symbol.define(required: true, allowed_values: %i[0% 5% 20%]),
          # default:    MeterAttributeTypes::Boolean.define(
          #               hint: 'Enable for group/site-wide tariffs where tariff is used as a fallback'),
          rates: MeterAttributeTypes::Hash.define(
            required: false,
            structure: {
              flat_rate: default_flat_rate,
              commodity_rate: default_flat_rate,
              non_commodity_rate: default_flat_rate,

              # enumerated hash keys as not sure front end can copy with an array?
              rate0: default_rate,
              rate1: default_rate,
              rate2: default_rate,
              rate3: default_rate,

              tiered_rate0: default_tiered_rate,
              tiered_rate1: default_tiered_rate,
              tiered_rate2: default_tiered_rate,
              tiered_rate3: default_tiered_rate,

              duos_red: MeterAttributeTypes::Float.define,
              duos_amber: MeterAttributeTypes::Float.define,
              duos_green: MeterAttributeTypes::Float.define,

              tnuos: MeterAttributeTypes::Boolean.define(
                hint: 'tick if transmission network use of system appears on bill'
              ),

              weekday: MeterAttributeTypes::Boolean.define,
              weekend: MeterAttributeTypes::Boolean.define
            }.merge(default_tariff_rates)
          ),
          asc_limit_kw: MeterAttributeTypes::Float.define,
          climate_change_levy: MeterAttributeTypes::Boolean.define,
          tariff_holder: MeterAttributeTypes::Symbol.define(required: false,
                                                            allowed_values: %i[
                                                              meter school school_group site_settings
                                                            ]),
          created_at: MeterAttributeTypes::DateTime.define(required: false)
        }
      )
    end

    structure generic_accounting_tariff
  end
end
