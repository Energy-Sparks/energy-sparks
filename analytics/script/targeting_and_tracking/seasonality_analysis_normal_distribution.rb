# research test program for trying seasonal fitting
# techniques for missing electricity data
require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/seasonal electricity fitting analysis ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def optimum_sd(school_weeks_kwh)
  optimum = Minimiser.minimize(10.0, 50.0) {|sd| difference_to_theoretical_profile(sd, school_weeks_kwh) }
  [optimum.x_minimum, optimum.f_minimum]
end

def difference_to_theoretical_profile(sd, school_weeks_kwh)
  theoretical_profile = SyntheticSeasonalSchoolWeeklyElectricityProfile.new(sd.to_f, school_weeks_kwh).profile
  difference(school_weeks_kwh, theoretical_profile)
end

def difference(school_profile, standard_profile)
  diff = 0.0
  school_profile.each_with_index do |val, index|
    diff += (val - standard_profile[index]).magnitude unless val.nan?
  end
  diff
end

def week_of_year(date)
  jan_1 = Date.new(date.year, 1, 1)
  sunday_of_week1 = jan_1 - jan_1.wday
  week = ((date - sunday_of_week1) / 7).to_i
end

def weekly_school_day_kwhs(school, fuel_type, start_date, end_date)
  meter = school.aggregate_meter(fuel_type)
  return {} if meter.nil? || meter.amr_data.start_date > start_date || meter.amr_data.end_date < end_date

  school_week_kwh       = Array.new(53, 0.0)
  school_week_day_count = Array.new(53, 0.0)

  (start_date..end_date).each do |date|
    next if school.holidays.day_type(date) != :schoolday

    week = week_of_year(date)

    school_week_kwh[week]       += meter.amr_data.one_day_kwh(date)
    school_week_day_count[week] += 1.0
  end

  average_school_day_kwh_by_week = school_week_kwh.map.with_index do |kwh, week|
    if school_week_day_count[week] > 2
      kwh / school_week_day_count[week]
    else
      Float::NAN
    end
  end

  total = average_school_day_kwh_by_week.map{ |v| v.nan? ? 0.0 : v }.sum

  school_day_kwh_by_week_normalised_to_1 = average_school_day_kwh_by_week.map { |kwh| kwh / total }
end

def sub_nil_nan(arr)
  arr.map { |v| v.nan? ? nil : v }
end

def save_csv(data)
  filename = "./Results/targeting_and_tracking_synthetic_distributions schools.csv"
  puts "Saving results to #{filename}"
  CSV.open(filename, 'w') do |csv|
    data.each do |school_name, week_avg_kwhs|
      csv << [school_name, sub_nil_nan(week_avg_kwhs)].flatten
    end
  end
end

class NormalDistributionProfile
  def initialize(sd, mean = 26, n = 52)
    @sd = sd
    @n = n
    @mean = mean
  end

  def profile
    dist = (0...@n).to_a.map { |x| normal_distribution(@sd, @mean, x) }
    sum = dist.sum
    normalised_to_1 = dist.map { |v| v / sum }
  end

  private

  def normal_distribution(sd, mean, x)
    (1.0 / (sd * ((2.0 * Math::PI) ** 0.5)) ) * Math.exp( -0.5 * (((x - mean)/sd) ** 2.0) )
  end
end

class SyntheticSeasonalSchoolWeeklyElectricityProfile
  attr_reader :profile
  def initialize(sd, weekly_kwhs)
    weeks_avg_kwh = map_to_weeks(NormalDistributionProfile.new(sd).profile)
    @profile = weeks_avg_kwh.map { |v| v * 52.0 / school_weeks(weekly_kwhs) }
  end

  private
  # norm profile lowest at either end, school ni middle in June
  # so remap, at [25] to make up to 53 weeks in year
  def map_to_weeks(profile)
     # profile[26..51] + profile[0..25] + profile[25..25]
     centre_week = 23
     profile[centre_week..51] + profile[0...centre_week] + profile[centre_week..centre_week]
  end

  def school_weeks(weekly_kwhs)
    weekly_kwhs.count{ |wkwh| !wkwh.nan? }
  end
end

class FitProfile
  def initialize(school_weeks_kwh)
    @standard_profiles = {}
    dist = {}
    (10..50).step(5).each do |sd|
      @standard_profiles[sd] = SyntheticSeasonalSchoolWeeklyElectricityProfile.new(sd.to_f, school_weeks_kwh).profile
    end
  end

  def best_match(school_profile)
    differences = {}
    @standard_profiles.each do |sd, standard_profile|
      differences[sd] = difference(school_profile, standard_profile)
    end

    min = differences.values.min
    sd = differences.key(min)

    { profile: @standard_profiles[sd], sd: sd }
  end

  private

  def difference(school_profile, standard_profile)
    diff = 0.0
    school_profile.each_with_index do |val, index|
      diff += (val - standard_profile[index]).magnitude unless val.nan?
    end
    diff
  end
end

def skip
  dist = {}
  (10..50).step(5).each do |sd|
    dist[sd] = SyntheticSeasonalSchoolWeeklyElectricityProfile.new(sd.to_f).profile
  end
  save_csv_dist(dist)
end

school_name_pattern_match = ['b*'] # ' ['abbey*', 'bathamp*']

source_db = :unvalidated_meter_data

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

ap school_names
data = {}
start_date = Date.new(2018, 7, 1)
end_date = Date.new(2019, 6, 30)

school_names.each do |school_name|
  school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)

  school_data = weekly_school_day_kwhs(school, :electricity, start_date, end_date)
  next if school_data.empty?
  data[school_name] = school_data
  fitter = FitProfile.new(school_data)
  match = fitter.best_match(school_data)
  sd1, eps = optimum_sd(school_data)
  puts "=" * 100
  puts "Optimum sd = #{sd1.round(1)} v. #{match[:sd]}"
  puts "="  * 100
  data["#{school_name} - ok fit #{sd1.round(1)}"]  = match[:profile]
  data["#{school_name} - best fit #{match[:sd]}"] = SyntheticSeasonalSchoolWeeklyElectricityProfile.new(sd1, school_data).profile
end

save_csv(data)

