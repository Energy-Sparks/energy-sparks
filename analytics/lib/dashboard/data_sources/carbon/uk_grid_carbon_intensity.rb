class GridCarbonIntensity < HalfHourlyData
  class NotInYearRange < StandardError; end

  def initialize
    super('UK Grid Carbon Intensity')
  end

  def grid_carbon_intensity(date, half_hour_index)
    data(date, half_hour_index)
  end

  def one_days_data_x48(date)
    add_parameterised_co2(date) if date_missing?(date)
    super(date)
  end

  def data(date, half_hour_index)
    add_parameterised_co2(date) if date_missing?(date)
    super(date, half_hour_index)
  end

  def one_day_total(date)
    add_parameterised_co2(date) if date_missing?(date)
    super(date)
  end

  # unlike other schedules maintain co2 as holey data, so start_date and end_date not valid
  def average_in_date_range(start_date, end_date)
    total = 0.0
    (start_date..end_date).each do |date|
      total += average(date)
    end
    total / (end_date - start_date + 1)
  end

  def start_date
    raise EnergySparksUnexpectedStateException, 'co2 maintained as holey data, so start_date not valid'
  end

  def end_date
    raise EnergySparksUnexpectedStateException, 'co2 maintained as holey data, so end_date not valid'
  end

  def self.grid_carbon_intensity_for_year_kg(year)
    @@grid_carbon_intensity_for_year_kg ||= {}
    @@grid_carbon_intensity_for_year_kg[year] ||= calculate_grid_carbon_intensity_for_year_kg(year)
  end

  private

  # lazy load dates outside range provided by the UK grid
  def add_parameterised_co2(date)
    add(date, Array.new(48, parameterised_co2(date)))
  end

  def parameterised_co2(date)
    hard_coded_mains_grid_intensity.select {|date_range| date >= date_range.first &&  date <= date_range.last }.values.first / 1_000.0
  end

  def hard_coded_mains_grid_intensity
    self.class.grid_intensity_parameters
  end

  def self.grid_intensity_parameters
    @@grid_intensity_parameters ||= create_data
  end

  private_class_method def self.calculate_grid_carbon_intensity_for_year_kg(year)
    raise NotInYearRange, "not in year range #{year}" unless year.between?(grid_intensity_parameters.keys.first.first.year, grid_intensity_parameters.keys.last.last.year)
    grid_intensity_parameters.each do |year_range, carbon_intensity|
      return carbon_intensity / 1000.0 if year == year_range.first.year
    end
    Float::NAN
  end

  def self.create_data
    {
      # https://www.mygridgb.co.uk/historicaldata/ - however (PH, 24Mar2019) thinks these are perhaps 30g/kWh too low?
      Date.new(2007,  1, 1)..Date.new(2007,  12, 31)  => 510.0,
      Date.new(2008,  1, 1)..Date.new(2008,  12, 31)  => 502.0,
      Date.new(2009,  1, 1)..Date.new(2009,  12, 31)  => 472.0,
      Date.new(2010,  1, 1)..Date.new(2010,  12, 31)  => 481.0,
      Date.new(2011,  1, 1)..Date.new(2011,  12, 31)  => 455.0,
      Date.new(2012,  1, 1)..Date.new(2012,  12, 31)  => 467.0,
      Date.new(2013,  1, 1)..Date.new(2013,  12, 31)  => 434.0,
      Date.new(2014,  1, 1)..Date.new(2014,  12, 31)  => 390.0,
      Date.new(2015,  1, 1)..Date.new(2015,  12, 31)  => 336.0,
      Date.new(2016,  1, 1)..Date.new(2016,  12, 31)  => 330.0,
      Date.new(2017,  1, 1)..Date.new(2017,   9, 18)  => 279.0,
      # from Energy Sparks grid carbon download - extracted from download csv file and grouped to week level
      Date.new(2017,  9, 19)..Date.new(2017,  9, 25)  => 268.9,
      Date.new(2017,  9, 19)..Date.new(2017,  9, 25)  => 268.9,
      Date.new(2017,  9, 19)..Date.new(2017,  9, 25)  => 268.9,
      Date.new(2017,  9, 26)..Date.new(2017,  10, 2)  => 227.5,
      Date.new(2017,  10, 3)..Date.new(2017,  10, 9)  => 219.3,
      Date.new(2017,  10, 10)..Date.new(2017,  10, 16)  => 217.1,
      Date.new(2017,  10, 17)..Date.new(2017,  10, 23)  => 265.9,
      Date.new(2017,  10, 24)..Date.new(2017,  10, 30)  => 248.3,
      Date.new(2017,  10, 31)..Date.new(2017,  11, 6)  => 282,
      Date.new(2017,  11, 7)..Date.new(2017,  11, 13)  => 300.8,
      Date.new(2017,  11, 14)..Date.new(2017,  11, 20)  => 347.7,
      Date.new(2017,  11, 21)..Date.new(2017,  11, 27)  => 308,
      Date.new(2017,  11, 28)..Date.new(2017,  12, 4)  => 380.8,
      Date.new(2017,  12, 5)..Date.new(2017,  12, 11)  => 350.7,
      Date.new(2017,  12, 12)..Date.new(2017,  12, 18)  => 361.9,
      Date.new(2017,  12, 19)..Date.new(2017,  12, 25)  => 285.4,
      Date.new(2017,  12, 26)..Date.new(2018,  1, 1)  => 218.3,
      Date.new(2018,  1, 2)..Date.new(2018,  1, 8)  => 268.9,
      Date.new(2018,  1, 9)..Date.new(2018,  1, 15)  => 296.4,
      Date.new(2018,  1, 16)..Date.new(2018,  1, 22)  => 243.2,
      Date.new(2018,  1, 23)..Date.new(2018,  1, 29)  => 219.6,
      Date.new(2018,  1, 30)..Date.new(2018,  2, 5)  => 262.8,
      Date.new(2018,  2, 6)..Date.new(2018,  2, 12)  => 264.6,
      Date.new(2018,  2, 13)..Date.new(2018,  2, 19)  => 268.8,
      Date.new(2018,  2, 20)..Date.new(2018,  2, 26)  => 327.6,
      Date.new(2018,  2, 27)..Date.new(2018,  3, 5)  => 381.1,
      Date.new(2018,  3, 6)..Date.new(2018,  3, 12)  => 332.7,
      Date.new(2018,  3, 13)..Date.new(2018,  3, 19)  => 310.5,
      Date.new(2018,  3, 20)..Date.new(2018,  3, 26)  => 311.8,
      Date.new(2018,  3, 27)..Date.new(2018,  4, 2)  => 258,
      Date.new(2018,  4, 3)..Date.new(2018,  4, 9)  => 238.3,
      Date.new(2018,  4, 10)..Date.new(2018,  4, 16)  => 258.2,
      Date.new(2018,  4, 17)..Date.new(2018,  4, 23)  => 188.4,
      Date.new(2018,  4, 24)..Date.new(2018,  4, 30)  => 223.7,
      Date.new(2018,  5, 1)..Date.new(2018,  5, 7)  => 206.9,
      Date.new(2018,  5, 8)..Date.new(2018,  5, 14)  => 208.9,
      Date.new(2018,  5, 15)..Date.new(2018,  5, 21)  => 223.7,
      Date.new(2018,  5, 22)..Date.new(2018,  5, 28)  => 211.1,
      Date.new(2018,  5, 29)..Date.new(2018,  6, 4)  => 253.3,
      Date.new(2018,  6, 5)..Date.new(2018,  6, 11)  => 254.6,
      Date.new(2018,  6, 12)..Date.new(2018,  6, 18)  => 205.2,
      Date.new(2018,  6, 19)..Date.new(2018,  6, 25)  => 233.7,
      Date.new(2018,  6, 26)..Date.new(2018,  7, 2)  => 242.1,
      Date.new(2018,  7, 3)..Date.new(2018,  7, 9)  => 267.2,
      Date.new(2018,  7, 10)..Date.new(2018,  7, 16)  => 268.6,
      Date.new(2018,  7, 17)..Date.new(2018,  7, 23)  => 270.7,
      Date.new(2018,  7, 24)..Date.new(2018,  7, 30)  => 204.6,
      Date.new(2018,  7, 31)..Date.new(2018,  8, 6)  => 222.9,
      Date.new(2018,  8, 7)..Date.new(2018,  8, 13)  => 227.1,
      Date.new(2018,  8, 14)..Date.new(2018,  8, 20)  => 200.8,
      Date.new(2018,  8, 21)..Date.new(2018,  8, 27)  => 193.2,
      Date.new(2018,  8, 28)..Date.new(2018,  9, 3)  => 254.4,
      Date.new(2018,  9, 4)..Date.new(2018,  9, 10)  => 237.3,
      Date.new(2018,  9, 11)..Date.new(2018,  9, 17)  => 214.9,
      Date.new(2018,  9, 18)..Date.new(2018,  9, 24)  => 201.1,
      Date.new(2018,  9, 25)..Date.new(2018,  10, 1)  => 231.2,
      Date.new(2018,  10, 2)..Date.new(2018,  10, 8)  => 230.9,
      Date.new(2018,  10, 9)..Date.new(2018,  10, 15)  => 210.6,
      Date.new(2018,  10, 16)..Date.new(2018,  10, 22)  => 261.5,
      Date.new(2018,  10, 23)..Date.new(2018,  10, 29)  => 209.9,
      Date.new(2018,  10, 30)..Date.new(2018,  11, 5)  => 273.9,
      Date.new(2018,  11, 6)..Date.new(2018,  11, 12)  => 208.3,
      Date.new(2018,  11, 13)..Date.new(2018,  11, 19)  => 271.4,
      Date.new(2018,  11, 20)..Date.new(2018,  11, 26)  => 341.1,
      Date.new(2018,  11, 27)..Date.new(2018,  12, 3)  => 233.3,
      Date.new(2018,  12, 4)..Date.new(2018,  12, 10)  => 232.4,
      Date.new(2018,  12, 11)..Date.new(2018,  12, 17)  => 253.7,
      Date.new(2018,  12, 18)..Date.new(2018,  12, 24)  => 256.1,
      Date.new(2018,  12, 25)..Date.new(2018,  12, 31)  => 232.4,
      Date.new(2019,  1, 1)..Date.new(2019,  1, 7)  => 294.8,
      Date.new(2019,  1, 8)..Date.new(2019,  1, 14)  => 247.1,
      Date.new(2019,  1, 15)..Date.new(2019,  1, 21)  => 287.3,
      Date.new(2019,  1, 22)..Date.new(2019,  1, 28)  => 273.5,
      Date.new(2019,  1, 29)..Date.new(2019,  2, 4)  => 286.7,
      Date.new(2019,  2, 5)..Date.new(2019,  2, 11)  => 214.5,
      Date.new(2019,  2, 12)..Date.new(2019,  2, 18)  => 185.9,
      Date.new(2019,  2, 19)..Date.new(2019,  2, 25)  => 204.5,
      Date.new(2019,  2, 26)..Date.new(2019,  3, 4)  => 229.1,
      Date.new(2019,  3, 5)..Date.new(2019,  3, 11)  => 178.4,
      Date.new(2019,  3, 12)..Date.new(2019,  3, 18)  => 174.4,
      Date.new(2019,  3, 19)..Date.new(2019,  3, 25)  => 231.9,
      Date.new(2019,  3, 20)..Date.new(2019,  12, 31)  => 210.0,
      # https://www.gov.uk/government/publications/valuation-of-energy-use-and-greenhouse-gas-emissions-for-appraisal
      # average of marginal and grid average values in Table 1 * 92% - seems best fit
      Date.new(2020,  1, 1)..Date.new(2020,  12, 31)  => 192.4,
      Date.new(2021,  1, 1)..Date.new(2021,  12, 31)  => 182.4,
      Date.new(2022,  1, 1)..Date.new(2022,  12, 31)  => 172.6,
      Date.new(2023,  1, 1)..Date.new(2023,  12, 31)  => 164.1,
      Date.new(2024,  1, 1)..Date.new(2024,  12, 31)  => 163.0,
      Date.new(2025,  1, 1)..Date.new(2025,  12, 31)  => 146.7,
      Date.new(2026,  1, 1)..Date.new(2026,  12, 31)  => 125.8,
      Date.new(2027,  1, 1)..Date.new(2027,  12, 31)  => 111.6,
      Date.new(2028,  1, 1)..Date.new(2028,  12, 31)  => 101.3,
      Date.new(2029,  1, 1)..Date.new(2029,  12, 31)  => 91.1,
      Date.new(2030,  1, 1)..Date.new(2030,  12, 31)  => 76.5,
      Date.new(2031,  1, 1)..Date.new(2031,  12, 31)  => 61.5,
      Date.new(2032,  1, 1)..Date.new(2032,  12, 31)  => 50.8,
      Date.new(2033,  1, 1)..Date.new(2033,  12, 31)  => 42.0,
      Date.new(2034,  1, 1)..Date.new(2034,  12, 31)  => 35.2,
      Date.new(2035,  1, 1)..Date.new(2035,  12, 31)  => 29.5,
      Date.new(2036,  1, 1)..Date.new(2036,  12, 31)  => 24.1,
      Date.new(2037,  1, 1)..Date.new(2037,  12, 31)  => 20.2,
      Date.new(2038,  1, 1)..Date.new(2038,  12, 31)  => 17.6
    }.freeze
  end
end

class GridCarbonLoader < HalfHourlyLoader
  def initialize(csv_file, carbon)
    super(csv_file, 0, 1, 0, carbon)
  end
end
