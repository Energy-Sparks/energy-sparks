require_relative '../utilities/format_energy_unit.rb'
class EnergyEquivalences
  def self.format_unit(value, unit)
    case unit
    when :£
      "£#{value}"
    when :kwh
      "#{value}kWh"
    when :co2
      "#{value}CO2 KG"
    else
      "#{value}#{unit.to_sym}"
    end
  end

  class X < FormatEnergyUnit # shorten name
  end

  J_TO_KWH = 1000.0 * 60 * 60

  #
  # updated with July 2025 figures - see the Analytics Benchmarking Values spreadsheet
  #
  def self.secr_co2_equivalence(old, attribute)
    if !Object.const_defined?('Rails') || Rails.env.test?
      old
    else
      SecrCo2Equivalence.find_by!(year: 2025)[attribute]
    end
  end

  UK_ELECTRIC_GRID_CO2_KG_KWH = secr_co2_equivalence(0.20493, :electricity_co2e_co2)
  UK_ELECTRIC_GRID_£_KWH = BenchmarkMetrics.pricing.electricity_price
  UK_DOMESTIC_ELECTRICITY_£_KWH = 0.2573

  UK_DOMESTIC_GAS_£_KWH = 0.0633
  UK_GAS_CO2_KG_KWH = secr_co2_equivalence(0.18253, :natural_gas_co2e_co2)
  UK_GAS_£_KWH = BenchmarkMetrics.pricing.gas_price
  GAS_BOILER_EFFICIENCY = 0.7

  WATER_ENERGY_LITRE_PER_K_J = 4200
  WATER_ENERGY_KWH_LITRE_PER_K = WATER_ENERGY_LITRE_PER_K_J / J_TO_KWH

  ICE_LITRES_PER_100KM = 7.1
  LITRE_PETROL_KWH = 9.6
  LITRE_PETROL_CO2_KG = 2.07047
  LITRE_PETROL_£ = 1.3415
  ICE_KWH_KM = 0.7767
  ICE_CO2_KM = 0.16984
  ICE_£_KM = 0.1071

  BEV_KWH_PER_KM = 0.188
  BEV_£_PER_KM = BEV_KWH_PER_KM * UK_DOMESTIC_ELECTRICITY_£_KWH

  SHOWER_TEMPERATURE_RAISE = 25.0
  SHOWER_LITRES = 50.0
  SHOWER_KWH_GROSS = (SHOWER_LITRES * SHOWER_TEMPERATURE_RAISE * WATER_ENERGY_LITRE_PER_K_J / J_TO_KWH).round(3)
  SHOWER_KWH_NET = (SHOWER_KWH_GROSS / GAS_BOILER_EFFICIENCY).round(3)
  SHOWER_£ = SHOWER_KWH_NET * UK_DOMESTIC_GAS_£_KWH
  SHOWER_CO2_KG = SHOWER_KWH_NET * UK_GAS_CO2_KG_KWH
  WATER_COST_PER_LITRE = 4.0 / 1000.0

  HOMES_ELECTRICITY_KWH_YEAR = 2_700
  HOMES_GAS_KWH_YEAR = 11_500
  HOMES_GAS_CO2_YEAR = HOMES_GAS_KWH_YEAR * UK_GAS_CO2_KG_KWH
  HOMES_KWH_YEAR = HOMES_ELECTRICITY_KWH_YEAR + HOMES_GAS_KWH_YEAR
  HOMES_ELECTRICITY_£_YEAR = HOMES_ELECTRICITY_KWH_YEAR * UK_DOMESTIC_ELECTRICITY_£_KWH
  HOMES_GAS_£_YEAR = HOMES_GAS_KWH_YEAR * UK_DOMESTIC_GAS_£_KWH
  HOMES_£_YEAR = HOMES_ELECTRICITY_£_YEAR + HOMES_GAS_£_YEAR

  KETTLE_LITRE_BY_85C_KWH = 85.0 * WATER_ENERGY_KWH_LITRE_PER_K
  KETTLE_LITRES = 1.5
  KETTLE_KWH = KETTLE_LITRES * KETTLE_LITRE_BY_85C_KWH
  KETTLE_£ = KETTLE_KWH * UK_DOMESTIC_ELECTRICITY_£_KWH

  SMARTPHONE_CHARGE_kWH = 20 / 1000
  SMARTPHONE_CHARGE_£ = SMARTPHONE_CHARGE_kWH * UK_DOMESTIC_ELECTRICITY_£_KWH

  ONE_HOUR = 1.0
  TV_POWER_KW = 0.04 # also kWh/hour
  TV_HOUR_£ = TV_POWER_KW * ONE_HOUR * UK_DOMESTIC_ELECTRICITY_£_KWH

  COMPUTER_CONSOLE_POWER_KW = 0.2 # also kWh/hour
  COMPUTER_CONSOLE_HOUR_£ = COMPUTER_CONSOLE_POWER_KW * ONE_HOUR * UK_DOMESTIC_ELECTRICITY_£_KWH

  TREE_LIFE_YEARS = 40
  TREE_CO2_KG_YEAR = 22
  TREE_CO2_KG = TREE_LIFE_YEARS * TREE_CO2_KG_YEAR # https://www.quora.com/How-many-trees-do-I-need-to-plant-to-offset-the-carbon-dioxide-released-in-a-flight

  LIBRARY_BOOK_£ = 5

  TEACHING_ASSISTANT_£_HOUR = 9.64

  # https://www.fcrn.org.uk/research-library/quantifying-carbon-footprint-catering-service-public-schools => 1.7kg meat, 1.3kg veggie in Italy
  # https://www.fcrn.org.uk/research-library/contribution-healthy-and-unhealthy-primary-school-meals-greenhouse-gas-emissions => 0.7kg
  # https://www.sciencedirect.com/science/article/pii/S1876610217328126 1.02kg/0.5kg
  CARNIVORE_DINNER_£ = 2.5
  CARNIVORE_DINNER_CO2_KG = 1.0
  VEGETARIAN_DINNER_£ = 1.5
  VEGETARIAN_DINNER_CO2_KG = 0.5

  ONSHORE_WIND_TURBINE_LOAD_FACTOR_PERCENT = 0.27
  ONSHORE_WIND_TURBINE_CAPACITY_KW = 500
  ONSHORE_WIND_TURBINE_AVERAGE_KW_PER_HOUR = ONSHORE_WIND_TURBINE_LOAD_FACTOR_PERCENT * ONSHORE_WIND_TURBINE_CAPACITY_KW * ONE_HOUR

  OFFSHORE_WIND_TURBINE_LOAD_FACTOR_PERCENT = 0.38
  OFFSHORE_WIND_TURBINE_CAPACITY_KW = 3000
  OFFSHORE_WIND_TURBINE_AVERAGE_KW_PER_HOUR = OFFSHORE_WIND_TURBINE_LOAD_FACTOR_PERCENT * OFFSHORE_WIND_TURBINE_CAPACITY_KW * ONE_HOUR

  SOLAR_PANEL_KWP = 350.0
  SOLAR_PANEL_YIELD_PER_KWH_PER_KWP_PER_YEAR = 0.7571428571
  SOLAR_PANEL_KWH_PER_YEAR = SOLAR_PANEL_KWP * SOLAR_PANEL_YIELD_PER_KWH_PER_KWP_PER_YEAR

  def self.all_equivalences(uk_electric_grid_co2_kg_kwh = UK_ELECTRIC_GRID_CO2_KG_KWH)
    # cache to save 2ms calculation time, maintain max 100 entries to limit memory footprint
    @@cached_equivalences = {} unless defined? @@cached_equivalences
    @@cached_equivalences.delete(@@cached_equivalences.keys[0]) if @@cached_equivalences.length > 100
    @@cached_equivalences[uk_electric_grid_co2_kg_kwh] ||= create_configuration(uk_electric_grid_co2_kg_kwh)
  end

  def self.equivalence_types(include_basic_types = true)
    list = include_basic_types ? all_equivalences(UK_ELECTRIC_GRID_CO2_KG_KWH) : all_equivalences(UK_ELECTRIC_GRID_CO2_KG_KWH).reject {|k, _v| [:electricity, :gas].include? k }
    list.keys
  end

  def self.equivalence_configuration(type, grid_intensity)
    all_equivalences(grid_intensity)[type]
  end

  def self.equivalence_conversion_configuration(type, kwh_co2_or_£, grid_intensity)
    all_equivalences(grid_intensity)[type][:conversions][kwh_co2_or_£]
  end

  def self.equivalence_choice_by_via_type(kwh_co2_or_£, grid_intensity)
    choices = all_equivalences(grid_intensity).select { |_equivalence, conversions| conversions[:conversions].key?(kwh_co2_or_£) }
    choices.keys
  end

  def self.equivalence_choice_by_via_type(kwh_co2_or_£)
    choices = all_equivalences(UK_ELECTRIC_GRID_CO2_KG_KWH).select { |_equivalence, conversions| conversions[:conversions].key?(kwh_co2_or_£) }
    choices.keys
  end

  private_class_method def self.create_configuration(uk_electric_grid_co2_kg_kwh)
    water_energy_description = "It takes #{X.format(:kwh, WATER_ENERGY_KWH_LITRE_PER_K)} of energy to heat 1 litre of water by 1C. "

    shower_description_to_kwh =\
      "1 shower uses #{X.format(:litre, SHOWER_LITRES)} of water, which is heated from 15C to 40C (25C rise). " +
      water_energy_description +
      "It therefore takes #{X.format(:litre, SHOWER_LITRES)} &times; #{X.format(:kwh, WATER_ENERGY_KWH_LITRE_PER_K)} &times; " +
      "#{SHOWER_TEMPERATURE_RAISE} = #{X.format(:kwh, SHOWER_KWH_GROSS)} to heat 1 litre of water by 20C. " +
      "However gas boilers are only #{GAS_BOILER_EFFICIENCY * 100.0} &percnt; efficient, so " +
      "#{X.format(:kwh, SHOWER_KWH_GROSS)} &divide; #{GAS_BOILER_EFFICIENCY} " +
      "= #{X.format(:kwh, SHOWER_KWH_NET)} of gas is required. ".freeze

    one_kettle_description_to_kwh =\
      water_energy_description +
      "It takes #{X.format(:kwh, WATER_ENERGY_KWH_LITRE_PER_K)} of energy to heat 1 litre of water by 1C. "\
      "A kettle contains about #{X.format(:litre, KETTLE_LITRES)} of water, which is heated by 85C from 15C to 100C. "\
      "Therefore it takes #{X.format(:litre, KETTLE_LITRES)} &times; 85C &times; #{X.format(:kwh, WATER_ENERGY_KWH_LITRE_PER_K)} "\
      "= #{X.format(:kwh, KETTLE_KWH)} of energy to boil 1 kettle. ".freeze

      ice_car_efficiency = "A petrol car uses #{X.format(:litre, ICE_LITRES_PER_100KM)} of fuel to travel 100 km (40 mpg). "

      ice_description_to_kwh =\
            ice_car_efficiency +
            "Each litre of petrol contains #{X.format(:kwh, LITRE_PETROL_KWH)} of energy, thus it takes "\
            "#{X.format(:litre, ICE_LITRES_PER_100KM)} &times; #{X.format(:kwh, LITRE_PETROL_KWH)}/l &divide; 100 km = "\
            "#{X.format(:kwh, ICE_KWH_KM)} for a car to travel 1 km. "
      ice_description_co2_kg =\
            ice_car_efficiency +
            "Each litre of petrol contains #{X.format(:co2, LITRE_PETROL_CO2_KG)}, thus the car emits "\
            "#{X.format(:litre, ICE_LITRES_PER_100KM)} &times; #{X.format(:kg, LITRE_PETROL_CO2_KG)}/l "\
            " &divide; 100 km = #{X.format(:co2, ICE_CO2_KM)} when it travels 1 km. "
      ice_description_to_£ =\
            ice_car_efficiency +
            "A litre of petrol costs about #{X.format(:£, LITRE_PETROL_£)} "\
            "so it costs #{X.format(:litre, ICE_LITRES_PER_100KM)} &times; #{X.format(:£, LITRE_PETROL_£)} &divide; 100km "\
            "= #{X.format(:£, ICE_£_KM)} to travel 1 km "\
            "(In reality if you include the costs of maintenance, servicing, depreciation "\
            "it can cost about £0.30/km to travel by car). "

    bev_co2_per_km = BEV_KWH_PER_KM * uk_electric_grid_co2_kg_kwh
    bev_efficiency_description = "An electric car uses #{X.format(:kwh, BEV_KWH_PER_KM)} of electricity to travel 1 km. "
    bev_co2_description = "An electric car emits #{X.format(:co2, bev_co2_per_km)} of electricity to travel 1 km (emissons from the National Grid). "

    homes_electricity_co2_year = HOMES_ELECTRICITY_KWH_YEAR * uk_electric_grid_co2_kg_kwh
    homes_co2_year = homes_electricity_co2_year + HOMES_GAS_CO2_YEAR

    kettle_co2_kg = KETTLE_KWH * uk_electric_grid_co2_kg_kwh

    smart_phone_charge_co2_kg = SMARTPHONE_CHARGE_kWH * uk_electric_grid_co2_kg_kwh

    tv_hour_co2_kg = TV_POWER_KW * ONE_HOUR * uk_electric_grid_co2_kg_kwh

    computer_console_co2_kg = COMPUTER_CONSOLE_POWER_KW * ONE_HOUR * uk_electric_grid_co2_kg_kwh

    {
      electricity: {
        description: '%s of electricity',
        conversions: {
          kwh:  {
            rate:         1.0,
            description:  ''
          },
          co2:  {
            rate:         uk_electric_grid_co2_kg_kwh,
            description:  "The UK electricity grid emitted an average of #{X.format(:co2, uk_electric_grid_co2_kg_kwh)} "\
                          "for every 1 kWh of electricity supplied during this period. "
          },
          £:  {
            rate:         UK_ELECTRIC_GRID_£_KWH,
            description:  "Electricity costs schools about £#{UK_ELECTRIC_GRID_£_KWH} per kWh. "
          }
        }
      },
      gas: {
        description: '%s of gas',
        conversions: {
          kwh:  {
            rate:         1.0,
            description:  ''
          },
          co2:  {
            rate:         UK_GAS_CO2_KG_KWH,
            description:  "The carbon intensity of gas is #{UK_GAS_CO2_KG_KWH}kg/kWh. ",
          },
          £:  {
            rate:         UK_GAS_£_KWH,
            description:  "Gas costs schools about £#{UK_GAS_£_KWH} per kWh. ",
          }
        }
      },
      ice_car: {
        description: 'driving a petrol car %s',
        conversions: {
          kwh:  {
            rate:                   ICE_KWH_KM,
            description:            ice_description_to_kwh,
            front_end_description:  'Distance (km) travelled by a petrol car (conversion using kwh)',
            adult_dashboard_wording:  'the energy needed to drive a petrol car %s'
          },
          co2:  {
            rate:         ICE_CO2_KM,
            description:  ice_description_co2_kg,
            front_end_description:  'Distance (km) travelled by a petrol car (conversion using co2)',
            adult_dashboard_wording:  'the CO2 emitted driving a petrol car %s'
          },
          £:  {
            rate:         ICE_£_KM,
            description:  ice_description_to_£,
            front_end_description:  'Distance (km) travelled by a petrol car (conversion using £)',
            adult_dashboard_wording:  'the cost of fuel to drive a petrol car %s'
          }
        },
        convert_to:       :km
      },
      bev_car: {
        description: 'driving a battery electric car %s',
        conversions: {
          kwh:  {
            rate:         BEV_KWH_PER_KM,
            description:  bev_efficiency_description,
            front_end_description:  'Distance (km) travelled by a battery electric car (conversion using kwh)',
            adult_dashboard_wording:  'the energy needed to drive a battery electric car %s'
          },
          co2:  {
            rate:         bev_co2_per_km,
            description:  bev_co2_description,
            front_end_description:  'Distance (km) travelled by a battery electric car (conversion using co2)',
            adult_dashboard_wording:  'the CO2 emitted driving a battery electric car %s',
          },
          £:  {
            rate:         BEV_£_PER_KM,
            description:  bev_efficiency_description,
            front_end_description:  'Distance (km) travelled by a battery electric car (conversion using £)',
            adult_dashboard_wording:  'the cost of fuel to drive a battery electric car %s',
          }
        },
        convert_to:       :km
      },
      home: {
        description: 'the annual energy consumption of %s',
        conversions: {
          kwh:  {
            rate:         HOMES_KWH_YEAR,
            description:  "An average uk home uses #{X.format(:kwh, HOMES_ELECTRICITY_KWH_YEAR)} of electricity "\
                          "and #{X.format(:kwh, HOMES_GAS_KWH_YEAR)} of gas per year, "\
                          "so a total of #{X.format(:kwh, HOMES_KWH_YEAR)}. ",
            front_end_description:  'The consumption of N average homes (conversion via kWh)',
            adult_dashboard_wording: 'the energy used by %s homes'
          },
          co2:  {
            rate:         homes_co2_year,
            description:  "An average uk home uses #{X.format(:kwh, HOMES_ELECTRICITY_KWH_YEAR)} of electricity "\
                          "and #{X.format(:kwh, HOMES_GAS_KWH_YEAR)} of gas per year. "\
                          "The carbon intensity of 1 kWh of electricity = #{X.format(:co2, uk_electric_grid_co2_kg_kwh)}/kWh and "\
                          "gas #{X.format(:co2, UK_GAS_CO2_KG_KWH)}/kWh. "\
                          "Therefore 1 home emits #{X.format(:kwh, HOMES_ELECTRICITY_KWH_YEAR)} &times; #{X.format(:co2, uk_electric_grid_co2_kg_kwh)} + "\
                          "#{X.format(:kwh, HOMES_GAS_KWH_YEAR)} &times; #{X.format(:co2, UK_GAS_CO2_KG_KWH)} = "\
                          "#{X.format(:co2, homes_co2_year)} per year. ",
            front_end_description:  'The consumption of N average homes (conversion via co2)',
            adult_dashboard_wording: 'the CO2 emitted by %s homes'
          },
          £:  {
            rate:         HOMES_£_YEAR,
            description:  "An average uk home uses #{X.format(:kwh, HOMES_ELECTRICITY_KWH_YEAR)} of electricity "\
                          "and #{X.format(:kwh, HOMES_GAS_KWH_YEAR)} of gas per year. "\
                          "For homes the cost of 1 kWh of electricity = #{X.format(:£, UK_DOMESTIC_ELECTRICITY_£_KWH)}/kWh and "\
                          "gas #{X.format(:£, UK_DOMESTIC_GAS_£_KWH)}/kWh. "\
                          "Therefore 1 home costs #{X.format(:kwh, HOMES_ELECTRICITY_KWH_YEAR)} &times; #{X.format(:£, UK_DOMESTIC_ELECTRICITY_£_KWH)} + "\
                          "#{X.format(:kwh, HOMES_GAS_KWH_YEAR)} &times; #{X.format(:£, UK_DOMESTIC_GAS_£_KWH)} = "\
                          "#{X.format(:£, HOMES_£_YEAR)} in energy per year. ",
            front_end_description:  'The consumption of N average homes (conversion via £)',
            adult_dashboard_wording: 'the energy cost of %s homes'
          }
        },
        convert_to:             :home,
        equivalence_timescale:  :year,
        timescale_units:        :home
      },
      homes_electricity: {
        description: 'the annual electricity consumption of %s',
        conversions: {
          kwh:  {
            rate:         HOMES_ELECTRICITY_KWH_YEAR,
            description:  "A average uk home uses #{X.format(:kwh, HOMES_ELECTRICITY_KWH_YEAR)} of electricity ",
            front_end_description:  'The consumption of N average homes electricity (conversion via kWh)',
            adult_dashboard_wording: 'the electricity consumption of %s homes'
          },
          co2:  {
            rate:         homes_electricity_co2_year,
            description:  "A average uk home uses #{X.format(:kwh, HOMES_ELECTRICITY_KWH_YEAR)} of electricity. "\
                          "The carbon intensity of 1 kWh of electricity = #{X.format(:co2, uk_electric_grid_co2_kg_kwh)}/kWh. "\
                          "Therefore 1 home emits #{X.format(:kwh, HOMES_ELECTRICITY_KWH_YEAR)} &times; #{X.format(:co2, uk_electric_grid_co2_kg_kwh)} = "\
                          "#{X.format(:co2, homes_electricity_co2_year)} per year. ",
            front_end_description:  'The consumption of N average homes electricity (conversion via co2)',
            adult_dashboard_wording: 'the CO2 emitted from electricity used in %s homes'
          },
          £:  {
            rate:         HOMES_ELECTRICITY_£_YEAR,
            description:  "An average uk home uses #{X.format(:kwh, HOMES_ELECTRICITY_KWH_YEAR)} of electricity. "\
                          "For homes the cost of 1 kWh of electricity = #{X.format(:£, UK_DOMESTIC_ELECTRICITY_£_KWH)}/kWh. "\
                          "Therefore 1 home costs #{X.format(:kwh, HOMES_ELECTRICITY_KWH_YEAR)} &times; #{X.format(:£, UK_DOMESTIC_ELECTRICITY_£_KWH)} = "\
                          "#{X.format(:£, HOMES_ELECTRICITY_£_YEAR)} in electricity per year. ",
            front_end_description:  'The consumption of N average homes electricity (conversion via £)',
            adult_dashboard_wording: 'the cost of electricity for %s homes'
          }
        },
        convert_to:             :home,
        equivalence_timescale:  :year,
        timescale_units:        :home
      },
      homes_gas: {
        description: 'the annual gas consumption of %s',
        conversions: {
          kwh:  {
            rate:         HOMES_GAS_KWH_YEAR,
            description:  "A average uk home uses #{X.format(:kwh, HOMES_GAS_KWH_YEAR)} of gas ",
            front_end_description:  'The consumption of N average homes gas (conversion via kWh)',
            adult_dashboard_wording: 'the gas consumption of %s homes'
          },
          co2:  {
            rate:         HOMES_GAS_CO2_YEAR,
            description:  "A average uk home uses #{X.format(:kwh, HOMES_GAS_KWH_YEAR)} of gas. "\
                          "The carbon intensity of 1 kWh of gas = #{X.format(:co2, UK_GAS_CO2_KG_KWH)}/kWh. "\
                          "Therefore 1 home emits #{X.format(:kwh, HOMES_GAS_KWH_YEAR)} &times; #{X.format(:co2, UK_GAS_CO2_KG_KWH)} = "\
                          "#{X.format(:co2, HOMES_GAS_CO2_YEAR)} per year. ",
            front_end_description:  'The consumption of N average homes gas (conversion via co2)',
            adult_dashboard_wording: 'the CO2 emitted from gas used to heat %s homes'
          },
          £:  {
            rate:         HOMES_GAS_£_YEAR,
            description:  "An average uk home uses #{X.format(:kwh, HOMES_GAS_KWH_YEAR)} of gas. "\
                          "For homes the cost of 1 kWh of gas = #{X.format(:£, UK_DOMESTIC_GAS_£_KWH)}/kWh. "\
                          "Therefore 1 home costs #{X.format(:kwh, HOMES_GAS_KWH_YEAR)} &times; #{X.format(:£, UK_DOMESTIC_GAS_£_KWH)} = "\
                          "#{X.format(:£, HOMES_GAS_£_YEAR)} in gas per year. ",
            front_end_description:  'The consumption of N average homes gas (conversion via £)',
            adult_dashboard_wording: 'the cost of heating %s homes'
          }
        },
        convert_to:             :home,
        equivalence_timescale:  :year,
        timescale_units:        :home
      },
      shower: {
        description: 'taking %s',
        conversions: {
          kwh:  {
            rate:                   SHOWER_KWH_NET,
            description:            shower_description_to_kwh,
            front_end_description:  'Number of showers (conversion via kWh)',
            adult_dashboard_wording:  'the energy used taking %s showers'
          },
          co2:  {
            rate:                   SHOWER_CO2_KG,
            description:            shower_description_to_kwh +
                                    "Burning 1 kwh of gas (normal source of heat for showers) emits #{X.format(:kg, UK_GAS_CO2_KG_KWH)} CO2. "\
                                    "Therefore 1 shower uses #{X.format(:kg, SHOWER_CO2_KG)} CO2. ",
            front_end_description:  'Number of showers (conversion via co2)',
            adult_dashboard_wording: 'the CO2 emitted taking %s showers'
          },
          £:  {
            rate:         SHOWER_£,
            description:  shower_description_to_kwh +
                          "1 kwh of gas costs #{X.format(:£, UK_GAS_£_KWH)}. "\
                          "Therefore 1 shower costs #{X.format(:kwh, SHOWER_KWH_NET)} &times; #{X.format(:£, UK_GAS_£_KWH)} = #{X.format(:£, SHOWER_£)} of gas. ",
            front_end_description:  'Number of showers (conversion via £)',
            adult_dashboard_wording: 'the cost of taking %s showers'
          }
        },
        convert_to:       :shower
      },
      kettle: {
        description: 'heating %s of water',
        conversions: {
          kwh:  {
            rate:         KETTLE_KWH,
            description:  one_kettle_description_to_kwh,
            front_end_description:  'Number of kettles boiled (conversion via kWh)',
            adult_dashboard_wording:  'the energy required to boil %s kettles'
          },
          co2:  {
            rate:         kettle_co2_kg,
            description:  one_kettle_description_to_kwh +
                          "And, heating 1 kettle emits #{X.format(:kwh, KETTLE_KWH)} &times; #{X.format(:co2, uk_electric_grid_co2_kg_kwh)}"\
                          " = #{X.format(:co2, kettle_co2_kg)}. ",
            front_end_description:  'Number of kettles boiled (conversion via co2)',
            adult_dashboard_wording:  'the CO2 emitted boiling %s kettles'
          },
          £:  {
            rate:         KETTLE_£,
            description:  one_kettle_description_to_kwh +
                          "Thus it costs #{X.format(:£, UK_ELECTRIC_GRID_£_KWH)} &times; #{X.format(:kwh, KETTLE_KWH)} = "\
                          "#{X.format(:£, KETTLE_£)} to boil a kettle. ",
            front_end_description:  'Number of kettles boiled (conversion via £)',
            adult_dashboard_wording:  'the cost of boiling %s kettles'
          }
        },
        convert_to:       :kettle
      },
      smartphone: {
        description: '%s',
        conversions: {
          kwh:  {
            rate:                   SMARTPHONE_CHARGE_kWH,
            description:            "It takes #{X.format(:kwh, SMARTPHONE_CHARGE_kWH)} to charge a smartphone. ",
            front_end_description:  'Number of charges of a smartphone (conversion via kWh)',
            adult_dashboard_wording:  'the energy needed to charge %s smartphones'
          },
          co2:  {
            rate:                   smart_phone_charge_co2_kg,
            description:            "It takes #{X.format(:kwh, SMARTPHONE_CHARGE_kWH)} to charge a smartphone. "\
                                    "Generating 1 kWh of electricity produces #{X.format(:co2, UK_ELECTRIC_GRID_£_KWH)}. "\
                                    "Therefore charging one smartphone produces #{X.format(:co2, smart_phone_charge_co2_kg)}. ",
            front_end_description:  'Number of charges of a smartphone (conversion via co2)',
            adult_dashboard_wording:  'the CO2 emitted charging %s smartphones'
          },
          £:  {
            rate:                   SMARTPHONE_CHARGE_£,
            description:            "It takes #{X.format(:kwh, SMARTPHONE_CHARGE_kWH)} to charge a smartphone. "\
                                    "Generating 1 kWh of electricity costs #{X.format(:£, UK_ELECTRIC_GRID_£_KWH)}. "\
                                    "Therefore charging one smartphone costs #{X.format(:£, SMARTPHONE_CHARGE_£)}. ",
            front_end_description:  'Number of charges of a smartphone (conversion via co2)',
            adult_dashboard_wording:  'the cost of charging %s smartphones'
          }
        },
        convert_to:       :smartphone
      },
      tv: {
        description: '%s',
        conversions: {
          kwh:  {
            rate:                   TV_POWER_KW,
            description:            "TVs use about #{X.format(:kwh, TV_POWER_KW)} of electricity every hour. ",
            front_end_description:  'Number of hours of TV usage (converted via kWh)',
            adult_dashboard_wording:  'the energy needed to run a TV for %s'
          },
          co2:  {
            rate:                   tv_hour_co2_kg,
            description:            "TVs use about #{X.format(:kwh, TV_POWER_KW)} of electricity every hour. "\
                                    "Generating 1 kWh of electricity produces #{X.format(:co2, UK_ELECTRIC_GRID_£_KWH)}. "\
                                    "Therefore using a TV for 1 hour produces #{X.format(:co2, tv_hour_co2_kg)}. ",
            front_end_description:  'Number of hours of TV usage (converted via co2)',
            adult_dashboard_wording:  'the CO2 emitted by a TV running for %s'
          },
          £:  {
            rate:         TV_HOUR_£,
            description:  "TVs use about #{X.format(:kwh, TV_POWER_KW)} of electricity every hour. "\
                          "Generating 1 kWh of electricity costs #{X.format(:£, UK_ELECTRIC_GRID_£_KWH)}. "\
                          "Therefore using a TV for 1 hour costs #{X.format(:£, TV_HOUR_£)}. ",
            front_end_description:  'Number of hours of TV usage (converted via £)',
            adult_dashboard_wording:  'the cost of running a TV for %s'
          }
        },
        convert_to:             :hour,
        equivalence_timescale:  :hour,
        timescale_units:        :tv
      },
      computer_console: {
        description: '%s',
        conversions: {
          kwh:  {
            rate:                   COMPUTER_CONSOLE_POWER_KW,
            description:            "Computer consoles use about #{X.format(:kwh, COMPUTER_CONSOLE_POWER_KW)} of electricity every hour. ",
            front_end_description:  'Number of hours of computer console usage (converted via kWh)',
            adult_dashboard_wording:  'the energy needed to run a computer console for %s'
          },
          co2:  {
            rate:                   computer_console_co2_kg,
            description:            "Computer consoles use about #{X.format(:kwh, COMPUTER_CONSOLE_POWER_KW)} of electricity every hour. "\
                                    "Generating 1 kWh of electricity produces #{X.format(:co2, UK_ELECTRIC_GRID_£_KWH)}. "\
                                    "Therefore using a computer console  for 1 hour produces #{X.format(:co2, computer_console_co2_kg)}. ",
            front_end_description:  'Number of hours of computer console  usage (converted via co2)',
            adult_dashboard_wording:  'the CO2 emitted by a computer console running for %s'
          },
          £:  {
            rate:         COMPUTER_CONSOLE_HOUR_£,
            description:  "Computer consoles use about #{X.format(:kwh, COMPUTER_CONSOLE_POWER_KW)} of electricity every hour. "\
                          "Generating 1 kWh of electricity costs #{X.format(:£, UK_ELECTRIC_GRID_£_KWH)}. "\
                          "Therefore using a computer console for 1 hour costs #{X.format(:£, COMPUTER_CONSOLE_HOUR_£)}. ",
            front_end_description:  'Number of hours of computer console  usage (converted via £)',
            adult_dashboard_wording:  'the cost of running a computer console for %s'
          }
        },
        convert_to:             :hour,
        equivalence_timescale:  :hour,
        timescale_units:        :computer_console
      },
      tree: {
        description: 'planting a %s (40 year life)',
        conversions: {
          co2:  {
            rate:                   TREE_CO2_KG,
            description:            "An average tree absorbs #{X.format(:co2, TREE_CO2_KG_YEAR)} per year. "\
                                    "And if the tree lives to #{TREE_LIFE_YEARS} years it will absorb "\
                                    "#{X.format(:co2, TREE_CO2_KG)}. ",
            front_end_description:  'Number of trees (40 year life, CO2 conversion)',
            adult_dashboard_wording:  'planting %s trees (CO2 emissions offset)'
          }
        },
        convert_to:       :tree
      },
      library_books: {
        description: 'the cost of %s',
        conversions: {
          £:  {
            rate:                   LIBRARY_BOOK_£,
            description:            "A library book costs about #{X.format(:£, LIBRARY_BOOK_£)}.",
            front_end_description:  'Number of library books (£5)',
            adult_dashboard_wording:  'the cost of %s library books'
          }
        },
        convert_to:       :library_books
      },
      teaching_assistant: {
        description: '%s',
        conversions: {
          £:  {
            rate:         TEACHING_ASSISTANT_£_HOUR,
            description:  "A school teaching assistant is paid on average #{X.format(:£, TEACHING_ASSISTANT_£_HOUR)} per hour.",
            front_end_description:  'Number of teaching assistant hours (£8.33/hour)',
            adult_dashboard_wording:  '%s teaching assistant support hours'
          }
        },
        convert_to:             :teaching_assistant_hours,
        equivalence_timescale:  :working_hours,
        timescale_units:        :teaching_assistant
      },
      carnivore_dinner: {
        description: '%s',
        conversions: {
          co2:  {
            rate:                   CARNIVORE_DINNER_CO2_KG,
            description:            "#{X.format(:co2, CARNIVORE_DINNER_CO2_KG)} of CO2 is emitted producing one dinner containing meat.",
            front_end_description:  'Number of meals containing meat (conversion via co2, 4kg/meal)',
            adult_dashboard_wording:  'the CO2 emitted producing %s school dinners'
          },
          £:  {
            rate:                   CARNIVORE_DINNER_£,
            description:            "One dinner containing meat costs #{X.format(:£, CARNIVORE_DINNER_£)}.",
            front_end_description:  'Number of meals containing meat (conversion via £, £2.50/meal)',
            adult_dashboard_wording:  'the cost of %s school dinners'
          }
        },
        convert_to:       :carnivore_dinner
      },
      vegetarian_dinner: {
        description: '%s',
        conversions: {
          co2:  {
            rate:                     VEGETARIAN_DINNER_CO2_KG,
            description:              "#{X.format(:co2, VEGETARIAN_DINNER_CO2_KG)} of CO2 is emitted producing one vegetarian dinner.",
            front_end_description:    'Number of vegetarian meals (conversion via co2, 2kg/meal)',
            adult_dashboard_wording:  'the CO2 emitted producing %s vegetarian meals'
          },
          £:  {
            rate:                     VEGETARIAN_DINNER_£,
            description:              "One vegetarian dinner costs #{X.format(:£, VEGETARIAN_DINNER_£)}.",
            front_end_description:    'Number of vegetarian meals (conversion via £, £1.50/meal)',
            adult_dashboard_wording:  'the cost of %s vegetarian meals'
          }
        },
        convert_to:       :vegetarian_dinner
      },
      onshore_wind_turbine_hours: {
        description: '%s',
        conversions: {
          kwh:  {
            rate:         ONSHORE_WIND_TURBINE_AVERAGE_KW_PER_HOUR,
            description:  "An average onshore wind turbine has a maximum capacity of #{X.format(:kw, ONSHORE_WIND_TURBINE_CAPACITY_KW)}. "\
                          "On average (wind varies) it is windy enough to use #{X.format(:percent, ONSHORE_WIND_TURBINE_LOAD_FACTOR_PERCENT)} of that capacity. "\
                          "Therefore an average onshore wind turbine generates about #{X.format(:kwh, ONSHORE_WIND_TURBINE_AVERAGE_KW_PER_HOUR)} per hour.",
            front_end_description:    'Number of onshore wind turbine hours (converted using kWh)',
            adult_dashboard_wording:  'the energy generated in %s by an onshore wind turbine'
          }
        },
        convert_to:       :onshore_wind_turbine_hours,
        equivalence_timescale:  :hour,
        timescale_units:        :onshore_wind_turbines
      },
      offshore_wind_turbine_hours: {
        description: '%s',
        conversions: {
          kwh:  {
            rate:         OFFSHORE_WIND_TURBINE_AVERAGE_KW_PER_HOUR,
            description:  "An average offshore wind turbine has a maximum capacity of #{X.format(:kw, OFFSHORE_WIND_TURBINE_CAPACITY_KW)}. "\
                          "On average (wind varies) it is windy enough to use #{X.format(:percent, OFFSHORE_WIND_TURBINE_LOAD_FACTOR_PERCENT)} of that capacity. "\
                          "Therefore an average offshore wind turbine generates about #{X.format(:kwh, OFFSHORE_WIND_TURBINE_AVERAGE_KW_PER_HOUR)} per hour.",
            front_end_description:    'Number of offshore wind turbine hours (converted using kWh)',
            adult_dashboard_wording:  'the energy generated in %s by an offshore wind turbine'
          }
        },
        convert_to:       :offshore_wind_turbine_hours,
        equivalence_timescale:  :hour,
        timescale_units:        :offshore_wind_turbines
      },
      solar_panels_in_a_year: {
        description: '%s',
        conversions: {
          kwh:  {
            rate:         SOLAR_PANEL_KWH_PER_YEAR,
            description:  "An average solar panel produces #{X.format(:kwh, SOLAR_PANEL_KWH_PER_YEAR)} per year. ",
            front_end_description:    'Number of solar panels in a year (converted using kWh)',
            adult_dashboard_wording:  'the energy generated by %s solar panels'
          }
        },
        convert_to:             :solar_panels_in_a_year,
        equivalence_timescale:  :year,
        timescale_units:        :solar_panels
      },
    }.freeze
  end
end
