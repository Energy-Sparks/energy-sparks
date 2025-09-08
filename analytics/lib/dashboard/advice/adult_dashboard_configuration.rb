require_rel './*.rb'
require_rel './../alerts/*/*.rb'
require_rel './../alerts/*/*/*.rb'

class DashboardConfiguration
  ADULT_DASHBOARD_GROUPS = {
    electric_group: %i[
      underlying_electricity_meters_breakdown
    ],
    gas_group: %i[
      underlying_gas_meters_breakdown
    ],
    boiler_control_group: %i[
      boiler_control_frost
    ]
  }.freeze

  ADULT_DASHBOARD_GROUP_CONFIGURATIONS = {
    boiler_control_frost: {
      name:                   'Frost',
      content_class:           AdviceGasBoilerFrost,
      excel_worksheet_name:   'Frost',
      charts: %i[frost],
      promoted_variables: {
      },
    },
    underlying_electricity_meters_breakdown: {
      name:                   'Electricity Meter Breakdown',
      content_class:           AdviceElectricityMeterBreakdownBase,
      excel_worksheet_name:   'ElectricBDown',
      charts: %i[ group_by_week_electricity_meter_breakdown_one_year ]
    },
    underlying_gas_meters_breakdown: {
      name:                   'Gas Meter Breakdown',
      content_class:           AdviceGasMeterBreakdownBase,
      excel_worksheet_name:   'GasBDown',
      charts: %i[ group_by_week_gas_meter_breakdown_one_year ]
    }
  }.freeze
end
