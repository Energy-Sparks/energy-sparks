require 'dashboard'

module Charts
  class Configuration
    def initialize(school, aggregated_meter_collection = nil)
      @school = school
      @aggregated_meter_collection = aggregated_meter_collection
    end

    def initial_page
      DashboardConfiguration::DASHBOARD_FUEL_TYPES[fuel_types][0]
    end

    def pages
      analyis_pages = dashboard_fuel_types[fuel_types]
      analyis_pages.reject {|page| page == :carbon_emissions && cannot?(:analyse, :carbon_emissions)} #if analyis_pages
    end

    def title(action_name)
      dashboard_page_configuration[action_name.to_sym][:name]
    end

    def charts(action_name)
      dashboard_page_configuration[action_name.to_sym][:charts]
    end

    def no_data?
      return true if @aggregated_meter_collection.nil?
      return true if @aggregated_meter_collection.aggregated_heat_meters.nil? && @aggregated_meter_collection.aggregated_electricity_meters.nil?
      @aggregated_meter_collection.aggregated_heat_meters.amr_data.nil? && @aggregated_meter_collection.aggregated_electricity_meters.amr_data.nil?
    end

    def fuel_types
      if dual_fuel?
        @school.dual_fuel_fuel_type
      elsif @school.meters_with_validated_readings(:electricity)
        @school.electricity_fuel_type
      elsif @school.meters_with_validated_readings(:gas)
        :gas_only
      else
        :none
      end
    end

    def dual_fuel?
      @school.meters_with_validated_readings(:gas) && @school.meters_with_validated_readings(:electricity)
    end

    def dashboard_page_configuration
      # This should check how many readings there is for both gas and electric (if dual fuel) etc
      DashboardConfiguration::DASHBOARD_PAGE_GROUPS

      # if not enough, then merge #.merge(LIMITED_DATA_DASHBOARD_PAGE_GROUPS)
    end

    def dashboard_fuel_types
      # This should check how many readings there is for both gas and electric (if dual fuel) etc
      DashboardConfiguration::DASHBOARD_FUEL_TYPES#.merge(LIMITED_DATA_DASHBOARD_FUEL_TYPES)

      # if not enough, then merge #.merge(LIMITED_DATA_DASHBOARD_FUEL_TYPES)
    end

    LIMITED_DATA_DASHBOARD_FUEL_TYPES = {
      electric_only:      %i[electricity_detail],
      gas_only:           %i[gas_detail boiler_control],
      electric_and_gas:   %i[electricity_detail gas_detail boiler_control],
    }.freeze

    LIMITED_DATA_DASHBOARD_PAGE_GROUPS = {
      main_dashboard_electric:  {
                                  name:   'Overview',
                                  charts: %i[]
                                },
      # Benchmark currently not working for Gas only
      main_dashboard_gas:  {
                                  name:   'Main Dashboard',
                                  charts: %i[]
                                },
      electricity_detail:      {
                                  name:   'Electricity Detail',
                                  charts: %i[
                                    group_by_week_electricity_unlimited
                                    baseload
                                    intraday_line_school_days_last5weeks
                                    intraday_line_school_last7days
                                  ]
                                },
      gas_detail:               {
                                  name:   'Gas Detail',
                                  charts: %i[
                                    group_by_week_gas_unlimited
                                    last_2_weeks_gas
                                    last_2_weeks_gas_degreedays
                                    last_7_days_intraday_gas
                                  ]
                                },
      main_dashboard_electric_and_gas: {
                                  name:   'Overview',
                                  charts: %i[]
                                },
      boiler_control:           {
                                  name: 'Advanced Boiler Control',
                                  charts: %i[
                                    frost_1
                                    frost_2
                                    frost_3
                                    thermostatic_control_large_diurnal_range_1
                                    thermostatic_control_large_diurnal_range_2
                                    thermostatic_control_large_diurnal_range_3
                                    thermostatic_control_medium_diurnal_range
                                  ]
                                },
    }.freeze
  end
end
