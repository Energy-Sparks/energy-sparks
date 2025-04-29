# Schedule data manager - temporary class to lazy load schedule data based on 'area' lookup
#                       - the 'areas' and lookup don;t exist for the moment (PH 14May2018)
#                       - but the initention is to consolidate the (CSV) data loading process
#                       - into a single location, so it can evenutally be replaced/supplemented
#                       - by a SQL loading process
#
# supported schedules are: holidays, temperatures, solar insolance, solar PV
class ScheduleDataManager
  include Logging

  # rubocop:disable Style/ClassVars
  @@holiday_data = {} # all indexed by area
  @@temperature_data = {}
  @@solar_irradiance_data = {}
  @@solar_pv_data = {}
  @@uk_grid_carbon_intensity_data = nil
  # rubocop:enable Style/ClassVars
  BATH_AREA_NAME = 'Bath'.freeze
  INPUT_DATA_DIR = File.join(File.dirname(__FILE__), '../../../InputData/')

  def self.holidays(area_name, calendar_id = nil)
    unless @@holiday_data.key?(area_name) # lazy load data if not already loaded
      check_area_name(area_name)
      area = AreaNames.key_from_name(area_name)
      hol_data = HolidayData.new
      filename = self.full_filepath(AreaNames.holiday_schedule_filename(area))
      HolidayLoader.new(filename, hol_data)
      puts "Loaded #{hol_data.length} holidays"
      hols = Holidays.new(hol_data)
      @@holiday_data[area_name] = hols
    end
    # Always return cache
    @@holiday_data[area_name]
  end

  def self.full_filepath(filename)
    "#{INPUT_DATA_DIR}/" + filename
  end

  def self.temperatures(area_name, temperature_area_id = nil)
    check_area_name(area_name)
    unless @@temperature_data.key?(area_name) # lazy load data if not already loaded

      temp_data = Temperatures.new('temperatures')

      area = AreaNames.key_from_name(area_name)
      filename = self.full_filepath(AreaNames.temperature_filename(area))
      TemperaturesLoader.new(filename, temp_data)
      puts "Loaded #{temp_data.length} days of temperatures"

      # pp temp_data.keys
      # temp_data is an object of type Temperatures
      @@temperature_data[area_name] = temp_data
    end
    @@temperature_data[area_name]
  end

  def self.solar_irradiation(area_name)
    check_area_name(area_name)
    unless @@solar_irradiance_data.key?(area_name) # lazy load data if not already loaded
      area = AreaNames.key_from_name(area_name)
      filename = self.full_filepath(AreaNames.solar_pv_filename(area))
      solar_data = SolarIrradianceFromPV.new('solar irradiance from pv')
      SolarPVLoader.new(filename, solar_data)
      puts "Loaded #{solar_data.length} days of solar irradiance data from #{filename}"
      @@solar_irradiance_data[area_name] = solar_data
    end
    @@solar_irradiance_data[area_name]
  end

  def self.solar_pv(area_name)
    check_area_name(area_name)
    unless @@solar_pv_data.key?(area_name) # lazy load data if not already loaded
      area = AreaNames.key_from_name(area_name)
      filename = self.full_filepath(AreaNames.solar_pv_filename(area))
      solar_data = SolarPV.new('solar pv')
      SolarPVLoader.new(filename, solar_data)
      puts "Loaded #{solar_data.length} days of solar pv data from #{filename}"
      @@solar_pv_data[area_name] = solar_data
    end
    @@solar_pv_data[area_name]
  end

  def self.uk_grid_carbon_intensity
    if @@uk_grid_carbon_intensity_data.nil?
      filename = INPUT_DATA_DIR + 'uk_carbon_intensity.csv'
      @@uk_grid_carbon_intensity_data = GridCarbonIntensity.new # rubocop:disable Style/ClassVars
      GridCarbonLoader.new(filename, @@uk_grid_carbon_intensity_data)
      puts "Loaded #{@@uk_grid_carbon_intensity_data.length} days of uk grid carbon intensity data"
    end
    @@uk_grid_carbon_intensity_data
  end

  def self.check_area_name(area)
    unless AreaNames.check_valid_area(area)
      raise EnergySparksUnexpectedSchoolDataConfiguration.new('Unexpected area configuration ' + area)
    end
  end
end
