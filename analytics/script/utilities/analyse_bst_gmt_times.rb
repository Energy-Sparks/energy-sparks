require 'require_all'
require_relative '../../lib/dashboard.rb'
require_rel '../../test_support'
require 'tzinfo'

module Logging
  @logger = Logger.new('log/gmt bst timezone analysis ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

def transition_times(back_years = 5)
  mid_summer = Date.new(Date.today.year, 6, 21)
  tz = TZInfo::Timezone.get('Europe/London')

  mid_summer_dates = (0..back_years).to_a.map { |year_offset| mid_summer - 365 * year_offset }

  mid_summer_dates.map do |date|
    period = tz.periods_for_local(date.to_time)[0]
    [
      period.local_start.to_date,
      period.local_end.to_date
    ]
  end
end

def summer_winter_time_transition_dates(back_years = 5)
  transition_times(back_years).flatten.sort.uniq.reverse.drop(1).reverse
end

def summer_times(back_years = 5)
  transition_times(back_years)
end

def amr_to_wallclock_time(amr_data, summer_times, mpxn)
  count = 0
  now = DateTime.now
  bm = Benchmark.realtime {
    summer_times.reverse.each do |(summer_start_date, summer_end_date)|
      start_date = [summer_start_date, amr_data.start_date].max
      end_date   = [summer_end_date, amr_data.end_date].min
      next if end_date < start_date

      (start_date..end_date).each do |date|
        kwh_x48_yesterday = date > amr_data.start_date ? amr_data.one_days_data_x48(date - 1) : amr_data.one_days_data_x48(date)
        kwh_x48_today = amr_data.one_days_data_x48(date)
        corrected_kwh_x48 = kwh_x48_yesterday[46..47] + kwh_x48_today[0..45]
        days_data = OneDayAMRReading.new(mpxn, date, 'ORIG', nil, now, corrected_kwh_x48)
        amr_data.add(date, days_data)
        count += 1
      end
    end
  }
  bm
end

def school_days_from_offset(school, transition_date, days: 5, direction: 1)
  school_day_dates= []
  date = transition_date
  while school_day_dates.length < days
    school_day_dates.push(date) if school.holidays.occupied?(date)
    date += direction
  end
  school_day_dates.sort
end

def transition_kwh(meter, date)
  kwh_x48 = meter.amr_data.one_days_data_x48(date)
  sorted_kwh_x48 = kwh_x48.sort
  peak_kwhs = sorted_kwh_x48.last(4).sum / 4.0
  baseload_kwhs = sorted_kwh_x48.first(4).sum / 4.0
  (peak_kwhs + baseload_kwhs) / 2.0
end

def first_transition_hh_index(meter, date, kwh)
  kwh_x48 = meter.amr_data.one_days_data_x48(date)
  (0..47).each do |hh_index|
    return hh_index if kwh_x48[hh_index] > kwh
  end
  nil
end

def last_transition_hh_index(meter, date, kwh)
  kwh_x48 = meter.amr_data.one_days_data_x48(date).reverse
  (0..47).each do |hh_index|
    return 47 - hh_index if kwh_x48[hh_index] > kwh
  end
  nil
end

def average_start_time(meter, dates)
  hh_times = dates.map do |date|
    kwh = transition_kwh(meter, date)
    first_transition_hh_index(meter, date, kwh)
  end.compact
  1.0 * hh_times.sum / hh_times.length
end

def average_end_time(meter, dates)
  hh_times = dates.map do |date|
    kwh = transition_kwh(meter, date)
    last_transition_hh_index(meter, date, kwh)
  end.compact
  1.0 * hh_times.sum / hh_times.length
end

def analyse_meter(school, meter, transition_dates)
  puts "#{school.name} #{meter.mpxn}"
  transition_shift = {}
  transition_dates.each do |transition_date|
    if meter.amr_data.start_date < transition_date - 10 &&
       meter.amr_data.end_date > transition_date + 10
      dates_before = school_days_from_offset(school, transition_date)

      before_time = average_start_time(meter, dates_before)
      dates_after = school_days_from_offset(school, transition_date, direction: -1)

      after_time = average_start_time(meter, dates_after)
      transition_shift[transition_date] = before_time - after_time
    else
      transition_shift[transition_date] = nil
    end
  end
  transition_shift
end

def save_to_csv(transition_dates, data)
  filename = "Results\\analyse meter bst-gmt times.csv"
  puts "Saving to #{filename}"
  CSV.open(filename, 'w') do |csv|
    csv << ['school', 'mpxn', 'conversion time', transition_dates].flatten
    data.each do |school_name, meters|
      meters.each do |mpxn, d|
        date_to_offset = d.select { | d, _offset| d.is_a?(Date) }
        csv << [school_name, mpxn, d[:t], date_to_offset.values].flatten
      end
    end
  end
end

transition_dates = summer_winter_time_transition_dates
ap transition_dates

school_name_pattern_match = ['bath*']
source_db = :unvalidated_meter_data
school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)
data = {}

school_names.each do |school_name|
  begin
    school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)
    electric_meters = school.electricity_meters # real_meters2.select { |meter| meter.fuel_type == :electricity }
    t = 0
    electric_meters.each do |meter|
      t  = amr_to_wallclock_time(meter.amr_data, summer_times, meter.mpxn)
      data[school_name] ||= {}
      data[school_name][meter.mpxn] = analyse_meter(school, meter, transition_dates)
      data[school_name][meter.mpxn][:t] = t
    end
  rescue => e
    puts "#{school_name} #{e.message}"
    puts e.backtrace
  end
end

ap data

save_to_csv(transition_dates, data)
