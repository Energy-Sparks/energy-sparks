require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'

module Logging
  @logger = Logger.new('log/sheffield_oversize_pv ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def save_statistics_to_csv(data)
  filename = File.join(TestDirectory.instance.results_directory('modelling'), 'sheffield_pv_stats.csv')
  puts "Saving results to #{filename}"
  CSV.open(filename, 'w') do |csv|
    csv << ['School name', 'mpan', 'peak consume kw', 'max pv capacity kw']
    data.each do |school_name, meters|
      meters.each do |mpxn, pv|
        csv << [school_name, mpxn, pv[:school_day_average_peak_kw], pv[:panel_capacity_kw]].flatten
      end
    end
  end
end

school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data

school_stats = {}

school_names = SchoolFactory.instance.school_file_list(source_db, school_name_pattern_match)

schools = school_names.map do |school_name|
  school = SchoolFactory.instance.load_school(source_db, school_name)

  if school.sheffield_simulated_solar_pv_panels?
    school.electricity_meters.each do |meter|
      next unless meter.sheffield_simulated_solar_pv_panels?
      puts "Got here for #{school_name}"
      school_stats[school_name] ||= {}
      school_stats[school_name][meter.mpxn] ||= {}

      peak_kw_stats = school.holidays.calculate_statistics(meter.amr_data.start_date, meter.amr_data.end_date, -> (date) { meter.amr_data.peak_kw(date) })
      gen_kw_stats= school.holidays.calculate_statistics(meter.amr_data.start_date, meter.amr_data.end_date, -> (date) { meter.sub_meters[:generation].amr_data.peak_kw(date) })

      school_stats[school_name][meter.mpxn][:school_day_average_peak_kw] = peak_kw_stats[:schoolday][:average]
      school_stats[school_name][meter.mpxn][:panel_capacity_kw] = gen_kw_stats[:schoolday][:max]
    end
  end
end

save_statistics_to_csv(school_stats)

ap school_stats