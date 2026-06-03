require 'fileutils'

class RecordTestTimes
  include Singleton

  def initialize(directory: default_test_directory)
    @rails = Object.const_defined?('Rails')
    @directory = directory
    @time_log = {}
    @calc_status = {}
  end

  def rails?
    @rails
  end

  def record_time(school_name, test_type, type)
    unless rails?
      r0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
    yield
    unless rails?
      t = Process.clock_gettime(Process::CLOCK_MONOTONIC) - r0
      log_time(school_name, test_type, type, t)
    end
  end

  def log_calculation_status(school_name, test_type, type, status)
    return if rails?

    @calc_status[school_name] ||= {}
    @calc_status[school_name][test_type] ||= {}
    @calc_status[school_name][test_type][type] = status
  end

  def save_csv
    return if rails?

    puts "Saving timing results to #{filename}"

    merged_results = @time_log.deep_merge(@calc_status)

    CSV.open(filename, 'w') do |csv|
      merged_results.each do |school_name, data|
        data.each do |test_type, test_data|
          test_data.each do |type, seconds|
            status = @calc_status.dig(school_name, test_type, type)
            csv << [test_type, school_name, type, @time_log[school_name][test_type][type], status] unless @time_log.dig(school_name, test_type, type).nil?
          end
        end
      end
    end
  end

  def print_stats
    return if rails?

    print_calc_stats_times(school_calc_times)
    print_calc_stats_times(type_calc_times)
  end

  def save_summary_stats_to_csv
    return if rails?

    save_summary_stats_to_csv_private(school_calc_times.deep_merge(type_calc_times))
  end

  private

  def default_test_directory
    return nil if Object.const_defined?('Rails')

    TestDirectory.instance.timing_directory
  end

  def log_time(school_name, test_type, type, seconds)
    @time_log[school_name] ||= {}
    @time_log[school_name][test_type] ||= {}
    @time_log[school_name][test_type][type] = seconds
  end

  def school_calc_times
    @school_calc_times ||= calculate_aggregate_school_calculation_times_by_type
  end

  def calculate_aggregate_school_calculation_times_by_type
    calc_times = {}
    @time_log.each do |school_name, test_type_data|
      test_type_data.each do |test_type, type_data|
        calc_times[school_name] ||= {}
        calc_times[school_name][test_type] ||= 0.0
        type_data.each do |_type, seconds|
          calc_times[school_name][test_type] += seconds || 0.0
        end
      end
    end
    calc_times
  end

  def type_calc_times
    @type_calc_times ||= calculate_aggregate_type_calculation_times
  end

  def calculate_aggregate_type_calculation_times
    calc_times = {}
    @time_log.each do |school_name, test_type_data|
      test_type_data.each do |test_type, type_data|
        calc_times[test_type] ||= {}

        type_data.each do |type, seconds|
          calc_times[test_type][type] ||= 0.0
          calc_times[test_type][type] += seconds || 0.0
        end
      end
    end
    calc_times
  end

  def print_calc_stats_times(calc_times)
    calc_times.each do |school_name_or_calc_type, test_type_data|
      test_type_data.each do |type, seconds|
        puts "#{sprintf('%-30.30s', school_name_or_calc_type)}: #{sprintf('%-30.30s', type)} #{sprintf('%3.2f', seconds)}"
      end
    end
  end

  def save_summary_stats_to_csv_private(stats)
    puts "Saving calculation summary stats to #{stats_filename}"

    CSV.open(stats_filename, 'w') do |csv|
      stats.each do |school_name_or_calc_type, test_type_data|
        test_type_data.each do |type, seconds|
          csv << [school_name_or_calc_type, type, seconds ]
        end
      end
    end
  end

  def filename
    File.join(@directory, "test timings #{DateTime.now.strftime('%Y%m%d %H%M%S')}.csv")
  end

  def stats_filename
    File.join(@directory, "calc stats #{DateTime.now.strftime('%Y%m%d %H%M%S')}.csv")
  end
end
