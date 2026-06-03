require 'require_all'
require_relative '../../lib/dashboard.rb'
require_all './test_support/'

module Logging
  filename = File.join(TestDirectory.instance.log_directory, 't and t annual kwh estimate ' + Time.now.strftime('%H %M') + '.log')
  @logger = Logger.new(filename)
  logger.level = :debug
end

def save_csv(results)
  filename = File.join(TestDirectory.instance.results_directory('modelling'), 'annual tnt estimate.csv')

  puts "Writing results to #{filename}"

  data_column_names = %i[days actual_kwh annual_kwh dec percent percent_days model_failed]

  column_names = [ 'school', 'fuel', data_column_names, 'fuel', data_column_names].flatten

  CSV.open(filename, 'w') do |csv|
    csv << column_names

    results.each do |name, school_data|

      electric = data_column_names.map { |cn| school_data.key?(:electricity) ? school_data[:electricity][cn] : nil}
      gas      = data_column_names.map { |cn| school_data.key?(:gas)         ? school_data[:gas][cn]         : nil }

      csv << [name, :electricity, electric, :gas, gas].flatten
    end
  end
end

def up_to_1_year_kwh(meter)
  start_date = [meter.amr_data.end_date - 365, meter.amr_data.start_date].max
  meter.amr_data.kwh_date_range(start_date, meter.amr_data.end_date)
end

def dec_estimates(school)
  DisplayEnergyCertificate.new.recent_aggregate_data(school.postcode)
end

def days_data(school, fuel_type)
  meter = school.aggregate_meter(fuel_type)
  return nil if meter.nil?

  meter.amr_data.days
end

def annual_estimate(meter)
  estimator = TargetingAndTrackingAnnualKwhEstimate.new(meter)
  estimator.calculate_apportioned_annual_estimate
rescue BivariateSolarTemperatureModel::BivariateModel::BivariateModelCalculationFailed => e
  puts "Electrical model failure: #{e.message}"
end

school_pattern_match = ['*']
source = :unvalidated_meter_data

school_list = SchoolFactory.instance.school_file_list(source, school_pattern_match)

results = {}

school_list.sort.each do |school_name|
  school = SchoolFactory.instance.load_school(source, school_name)

  dec = dec_estimates(school)

  results[school.name] = {}

  %i[electricity gas].each do |fuel_type|
    meter = school.aggregate_meter(fuel_type)
    next if meter.nil?

    dec_estimate_kwh = fuel_type == :electricity ? dec[:electricity_kwh] : dec[:heating_kwh]

    days = days_data(school, fuel_type)

    results[school.name][fuel_type] = if days  >= 365
                          {
                            days:         days,
                            actual_kwh:   up_to_1_year_kwh(meter),
                            dec:          dec_estimate_kwh
                          }
                         else
                          estimate = annual_estimate(meter)

                          if estimate.nil?
                            {
                              days:         days,
                              dec:          dec_estimate_kwh,
                              model_failed: true
                            }
                          else
                            {
                              days:         days,
                              actual_kwh:   meter.amr_data.total,
                              annual_kwh:   estimate,
                              percent:      meter.amr_data.total / estimate,
                              percent_days: days / 365.0,
                              dec:          dec_estimate_kwh,
                              model_failed: false
                            }
                          end
                        end
  end
end

save_csv(results)
