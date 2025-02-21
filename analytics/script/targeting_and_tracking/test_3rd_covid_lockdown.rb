require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/covid lockdown testing ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def sub_nil_nan(arr)
  arr.map { |v| v.nan? ? nil : v }
end

def save_reductions(filename, data)
  puts "Saving results to #{filename}"
  CSV.open(filename, 'w') do |csv|
    csv << ['school name', 'v. Autumn 2020 mirrored', 'v. Spring 2020', '2020-2021 before', '2020-2021 after']
    data.each do |school_name, percent_reduction|
      csv << [school_name, sub_nil_nan(percent_reduction)].flatten
    end
  end
end

def save_csv(filename, data)
  puts "Saving results to #{filename}"
  CSV.open(filename, 'w') do |csv|
    data.each do |school_name, week_avg_kwhs|
      csv << [school_name, sub_nil_nan(week_avg_kwhs)].flatten
    end
  end
end

# CONFIG

filename = "./Results/targeting_and_tracking_3rd covid lockdown schools.csv"
reduction_filename = "./Results/targeting_and_tracking_3rd covid lockdown schools reduction stats.csv"
school_name_pattern_match = ['abbey*', 'bathamp*']
start_date = Date.new(2020, 7, 1)
end_date = Date.new(2021, 6, 30)
fuel_type = :electricity
source_db = :unvalidated_meter_data

# RUN SCRIPT:

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)

ap school_names
data = {}
lockdown_reduction = {}

school_names.each do |school_name|
  school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)

  meter = school.aggregate_meter(fuel_type)
  next if meter.nil?

  seasonal = Covid3rdLockdownElectricityCorrection.new(meter, school.holidays)

  info = seasonal.adjusted_amr_data

  lockdown_reduction[school_name] = []
  lockdown_reduction[school_name].push(info[:feedback][:percent_reduction_versus_Oct_Dec_2020])
  lockdown_reduction[school_name].push(info[:feedback][:percent_reduction_versus_Jan_Mar_2020])

  ed = meter.amr_data.end_date
  sd = ed - 365
  before = meter.amr_data.kwh_date_range(sd, ed)
  after = info[:amr_data].kwh_date_range(sd, ed)
  puts "3rd lock down adjustment of AMRData before #{before} after #{after}"
  lockdown_reduction[school_name].push(before)
  lockdown_reduction[school_name].push(after)

=begin

  fitter = MissingELectricityNormalDistributionProfileWeeklyFitter.new(meter.amr_data, school.holidays, start_date, end_date)
  fitted_data = fitter.fit
  next if fitted_data.nil?

  covid_3 = ThirdLockdownElectricityCovidAdjustment.new(meter.amr_data, school.holidays, start_date, end_date)
  covid_3.needs_adjustment?

  data["#{school_name} - actual"] = fitted_data[:actual]
  data["#{school_name} - best fit #{fitted_data[:sd].round(1)}"] = fitted_data[:profile]
=end
end

ap lockdown_reduction

save_reductions(reduction_filename, lockdown_reduction)
exit
save_csv(filename, data)
