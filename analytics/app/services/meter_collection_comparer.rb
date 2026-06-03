# frozen_string_literal: true

# Compares 2 meter collections: primarily for testing of feeds or meter validations
# has various levels of verbosity/detail
# bespoke implementaton, did review HashDiff gem, but not suitable/specific enough
#
class MeterCollectionReconciler
  include Logging

  attr_reader :deleted_meters, :inserted_meters, :matching_meters

  def initialize(existing_meter_collection, new_meter_collection)
    @existing_meter_collection = existing_meter_collection
    @existing_meter_list = id_to_meter_map(existing_meter_collection)

    @new_meter_collection = new_meter_collection
    @new_meter_list = id_to_meter_map(new_meter_collection)
    @meter_reading_comparisons = {}
  end

  def compare
    logger.info "Comparing meters for #{@new_meter_collection.name}"
    @deleted_meters, @inserted_meters, @matching_meters = compare_meters

    matching_meters.each do |meter1, meter2|
      meter_reconciler = MeterReconciler.new(meter1, meter2)
      meter_reconciler.compare_meter_readings
      @meter_reading_comparisons[meter1.id] = meter_reconciler
    end
  end

  def meters_with_percent_change_above(percent)
    @meter_reading_comparisons.select { |_id, reconciler| reconciler.percent > percent }
  end

  def print_comparison(verbosity = 0)
    if verbosity >= 0
      logger.info "Comparing meters for meter_collection #{@existing_meter_collection.name}"
      logger.info "  #{deleted_meters.length} deleted meters #{inserted_meters.length} new meters from #{matching_meters.length} matching"
    end
    return unless verbosity >= 1

    @meter_reading_comparisons.each_value do |meter_readings_comparison|
      meter_readings_comparison.print_comparison(verbosity)
    end
  end

  private

  def id_to_meter_map(meter_collection)
    meter_collection.all_meters.map { |meter| [meter.id, meter] }.to_h
  end

  def compare_meters
    inserted = @existing_meter_list.reject { |id, _meter| @new_meter_list.key?(id) }
    deleted = @new_meter_list.reject { |id, _meter| @existing_meter_list.key?(id) }
    same_ids = @new_meter_list.keys.select { |id| @existing_meter_list.key?(id) }
    same = same_ids.map { |id| [@existing_meter_list[id], @new_meter_list[id]] } # pair of meters
    [deleted.values, inserted.values, same]
  end

  class MeterReconciler
    include Logging
    attr_reader :inserted, :deleted, :changed, :id, :deleted_kwh, :inserted_kwh, :changed_kwh, :percent

    def initialize(meter1, meter2)
      @meter1 = meter1
      @meter2 = meter2
      @id = meter1.id
    end

    def compare_meter_readings
      amr_data1 = @meter1.amr_data
      amr_data2 = @meter2.amr_data

      @inserted = amr_data2.select { |date, _amr_data| amr_data1.date_missing?(date) }.values
      @deleted = amr_data1.select { |date, _amr_data| amr_data2.date_missing?(date) }.values

      changed_dates = amr_data1.keys.select { |date| amr_data1.date_exists?(date) && amr_data2.date_exists?(date) && amr_data1[date] != amr_data2[date] }
      @changed = changed_dates.map { |date| [amr_data1[date], amr_data2[date]] }

      logger.info "Comparing amr readings for #{@meter1.id} #{@meter1.name}: #{@deleted.length} deleted #{@inserted.length} inserted #{@changed.length} changed"
      logger.info "Value #{total_meter_readings_kwh(@inserted).round(0)} kwh"
      @deleted_kwh, @inserted_kwh, @changed_kwh = kwh_changes
      @percent = (@deleted_kwh.magnitude + @inserted_kwh.magnitude + @changed_kwh.magnitude) / total_meter1_kwh
    end

    def print_comparison(verbosity)
      print_summary_comparison  if verbosity >= 1
      print_type_statistics     if verbosity >= 2
      print_reading_diffs       if verbosity >= 3
    end

    def analyse_change_correction_type_statistics
      type_count = Hash.new(0)
      kwh_stats = Hash.new(0.0)
      @changed.each do |day1, day2|
        key = day1.type == day2.type ? day1.type : "#{day1.type}=>#{day2.type}"
        type_count[key] += 1
        kwh_stats[key] += day1.one_day_kwh - day2.one_day_kwh
      end
      [type_count, kwh_stats]
    end

    def print_reading_diffs
      @changed.each do |day1, day2|
        decimal_places = 3
        begin
          decimal_places = 1 + [Math.log10(day1.kwh_data_x48.max), Math.log10(day2.kwh_data_x48.max)].max
        rescue StandardError
          puts "Failure to determine decimal places for #{id} #{day1.date}"
        end
        print_one_day_reading(day1, decimal_places)
        print_one_day_reading(day2, decimal_places)
        logger.info '' # new line
      end
    end

    def print_one_day_reading(day, decimal_places)
      date = day.date.strftime('%a %d-%m-%Y')
      sub_date = day.substitute_date.nil? ? '              ' : day.substitute_date.strftime('%a %d-%m-%Y')
      total = format('%6.1f', day.one_day_kwh)
      halfhour_readings = day.kwh_data_x48.map { |hh_kwh| format('%*.0f', decimal_places, hh_kwh) }
      logger.info "        #{date} #{sub_date} #{day.type} #{total}: #{halfhour_readings.join(',')}"
    end

    def print_type_statistics
      change_type_stats, kwh_stats = analyse_change_correction_type_statistics
      change_type_stats.each do |type, count|
        kwh = kwh_stats[type].nan? ? kwh_stats[type] : kwh_stats[type].round(0)
        logger.info format('      %-10.10s x %4d %6.0fkwh', type, count, kwh)
      end
    end

    def print_summary_comparison
      deleted_kwh, inserted_kwh, changed_kwh = kwh_changes

      logger.info "  Comparing amr readings for #{@meter1.id} #{@meter1.name}:"
      logger.info "    #{change_desc(@deleted,  'deleted', deleted_kwh)}#{change_desc(@inserted, 'inserted', inserted_kwh)}#{change_desc(@changed, 'changed', changed_kwh)}"
    end

    def kwh_changes
      deleted_kwh = total_meter_readings_kwh(@deleted).round(0)
      inserted_kwh = total_meter_readings_kwh(@inserted).round(0)
      changed_kwh = difference_in_changed_meter_readings_kwh
      changed_kwh = changed_kwh.round(0) unless changed_kwh.nan?
      [deleted_kwh, inserted_kwh, changed_kwh]
    end

    def change_desc(diffs, desc, kwh)
      percent = 100.0 * (kwh / total_meter1_kwh)
      "#{diffs.length} #{desc} (#{kwh}kwh #{percent.round(1)}%) "
    end

    def total_meter1_kwh
      @meter1.amr_data.total
    end

    def total_meter_readings_kwh(meter_readings)
      meter_readings.inject(0) { |sum, one_reading| sum + one_reading.one_day_kwh.magnitude }
    end

    def difference_in_changed_meter_readings_kwh
      @changed.inject(0.0) { |sum, days| sum + days[0].one_day_kwh.magnitude - days[1].one_day_kwh.magnitude }
    end
  end
end
