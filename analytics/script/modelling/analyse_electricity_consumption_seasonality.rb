# research for a model for electricity use in schools
# basic model: linear regression between daily kWh usage and outside temperature and solar irradiation
# this is an attempt to represent the seasonaility in electricity usein schools
# runs on school days only, skips COVID school lockdown periods
require 'require_all'
require_relative '../lib/dashboard.rb'
require_rel '../test_support'
require './script/report_config_support.rb'
require 'ruby-prof'
require 'write_xlsx'

profile = false

module Logging
  @logger = Logger.new('log/electricity seasonality ' + Time.now.strftime('%H %M') + '.log')
  logger.level = :debug
end

class AnalyseElectricitySeasonality
  def initialize(school)
    @school = school
    @amr_data = school.aggregated_electricity_meters.amr_data if electricity_meter?
  end

  def analyse(method)
    res = nil
    bm = Benchmark.realtime {
      res = analyse_timed(method)
    }
    puts "Calculated regressions in #{bm.round(3)} seconds"
    res
  end

  def model_corrections
    {
      90000000114230 => { min_kwh: 280.0 }      # Durham St Margarets: seems to be a misclasification of school days
    }
  end

  def correction
    model_corrections[@school.aggregated_electricity_meters.mpan_mprn.to_i]
  end

  def analyse_timed(method)
    return [nil, nil] unless electricity_meter?
    days_kwhs = []
    sol_yield = []
    temperatures = []
    dates = []

    case method
    when :raw
      process_all_data(dates, days_kwhs, sol_yield, temperatures)
    when :without_bottom_10_percent
      process_all_data_minus_bottom_10_percent(school_days, dates, days_kwhs, sol_yield, temperatures)
    when :most_recent_300_school_days_without_bottom_10_percent
      process_all_data_minus_bottom_10_percent(school_days.last(300), dates, days_kwhs, sol_yield, temperatures)
    end

    regress_data(dates, days_kwhs, temperatures, sol_yield)
  end

  def process_all_data(dates, days_kwhs, sol_yield, temperatures)
    school_days.each do |date|
      dates.push(date)
      days_kwhs.push(@amr_data.one_day_kwh(date))
      sol_yield.push(@school.solar_irradiation.average(date))
      temperatures.push(@school.temperatures.average(date))
    end
  end

  def process_all_data_minus_bottom_10_percent(selected_days, dates, days_kwhs, sol_yield, temperatures)
    date_to_kwh = selected_days.map do |date|
      [date, @amr_data.one_day_kwh(date)]
    end.to_h

    top_90_percent_kwhs = date_to_kwh.values.sort{ |a,b| a <=> b }.last( (0.9 * date_to_kwh.length).to_i )

    hurdle = correction.nil? || correction[:min_kwh].nil? ? top_90_percent_kwhs.first : correction[:min_kwh]

    top_90_percent_date_to_kwh = date_to_kwh.select { |_date, kwh| kwh > hurdle }

    top_90_percent_date_to_kwh.keys.sort.each do |date, kWh|
      dates.push(date)
      days_kwhs.push(top_90_percent_date_to_kwh[date])
      sol_yield.push(@school.solar_irradiation.average(date))
      temperatures.push(@school.temperatures.average(date))
    end
  end

  def regress_data(dates, days_kwhs, temperatures, sol_yield)
    sa, sb, sr2, slb = regression(days_kwhs, sol_yield, 'SI')
    ta, tb, tr2, tlb = regression(days_kwhs, temperatures, 'T')
    mr2, ms, mt, mc, mlb = multi_regression(days_kwhs, temperatures, sol_yield, 'T', 'SI')
    n = days_kwhs.length

    predictions, differences, percent_diffs = difference_from_model(ms, mt, mc, days_kwhs, temperatures, sol_yield)

    sd = model_percent_standard_deviation = EnergySparks::Maths.standard_deviation(percent_diffs)

    [
      [@school.name, sa, sb, sr2, ta, tb, tr2, mr2, school_days.length, model_percent_standard_deviation],
      {
        name:                    @school.name,
        mpan:                    @school.aggregated_electricity_meters.mpan_mprn,
        solar_meta:              { constant: sa, slope: sb, r2: sr2, n: n, label: slb},
        temperature_meta:        { constant: ta, slope: tb, r2: tr2, n: n, label: tlb},
        solar_temperature_meta:  { constant: mc, slope_solar: ms, slope_temperature: mt, r2: mr2, n: n, label: mlb, sd: sd},
        date:   dates,
        kwh:    days_kwhs,
        temp:   temperatures,
        solar:  sol_yield,
        model:  predictions,
        difference_from_model: differences,
        percent_diffs: percent_diffs
      }
    ]
  end

  private

  def difference_from_model(ms, mt, mc, days_kwhs, temperatures, sol_yield)
    predictions = []
    differences = []
    percent_diffs = []

    days_kwhs.each_with_index do |kwh, date_index|
      prediction = mc + ms * sol_yield[date_index] + mt * temperatures[date_index]
      difference = kwh - prediction
      predictions.push(prediction)
      differences.push(difference)
      percent_diffs.push(percent(kwh, difference))
    end
    [predictions, differences, percent_diffs]
  end

  def percent(val, difference)
    val == 0.0 ? 0.0 : difference / val
  end

  def electricity_meter?
    !@school.aggregated_electricity_meters.nil?
  end

  def school_days
    @school_days ||= dates_to_analyse
  end

  def dates_to_analyse
    dates = []
    start_date = [@amr_data.start_date, Date.new(2014,1,1)].max # solar pv data starts in 2014
    (start_date..@amr_data.end_date).each do |date|
      dates.push(date) if school_day?(date) && ['ORIG', 'STEX'].include?(@amr_data.substitution_type(date))
    end
    dates
  end

  def regression(v1, v2, var_name)
    x = Daru::Vector.new(v1)
    y = Daru::Vector.new(v2)
    sr = Statsample::Regression.simple(x, y)
    label = "#{sr.a.round(1)} + #{sr.b.round(4)} * #{var_name}; r2 #{sr.r2.round(2)}"
    [sr.a, sr.b, sr.r2, label]
  end

  def multi_regression(kwhs, temperatures, irradiation, var_name1, var_name2)
    x1 = Daru::Vector.new(temperatures)
    x2 = Daru::Vector.new(irradiation)
    y = Daru::Vector.new(kwhs)
    ds = Daru::DataFrame.new({:temperatures => x1, :irradiation => x2, :kwh => y})
    lr = Statsample::Regression.multiple(ds, :kwh)
    label = "#{lr.constant.round(1)} + #{lr.coeffs[:temperatures].round(4)} * #{var_name1} + #{lr.coeffs[:irradiation].round(4)} * #{var_name2}; r2 #{lr.r2.round(2)}"
    [lr.r2, lr.coeffs[:irradiation], lr.coeffs[:temperatures], lr.constant, label]
  end

  def school_day?(date)
    !@school.holidays.holiday?(date) &&
    !DateTimeHelper.weekend?(date) &&
    !covid_date?(date)
  end

  def covid_date?(date)
    (date > Date.new(2020,3,20) && date < Date.new(2020,9,1)) ||
    date > Date.new(2021,1,3)
  end
end


class ExcelScatterChart
  def initialize
    filename = 'Results\electricity seasonal analysis detail.xlsx'
    @workbook  = WriteXLSX.new(filename)
  end

  def close
    @workbook.close
  end

  def sheet_ref(worksheet, r1, c1, r2, c2)
    ref1 =  worksheet.xl_rowcol_to_cell(r1, c1, true, true)
    ref2 =  worksheet.xl_rowcol_to_cell(r2, c2, true, true)
    "=#{worksheet.name}!#{ref1}:#{ref2}"
  end

  def sheet_ref_local(worksheet, r, c)
    worksheet.xl_rowcol_to_cell(r, c)
  end

  def save(all_data, name)
    brd = 10 # base row for data

    worksheet = @workbook.add_worksheet(name)

    all_data.each_with_index do |data_set, index|
      base_column = index * 16

      raw_data = data_set.select { |k, _v| %i[date kwh temp solar model difference_from_model percent_diffs].include?(k) }
      meta_data = data_set.select { |k, _v| !%i[date kwh temp solar model difference_from_model percent_diffs].include?(k) }
      meta_data_grid = meta_data.map do |k, v|
        [k.to_s, pad(v.is_a?(Hash) ? v.map { |kk,vv| [kk.to_s, vv]}.flatten : [v], 14)].flatten
      end.transpose

      raw_data = remove_nan(raw_data)
      meta_data_grid = remove_nan(meta_data_grid)

      data = raw_data.map{ |k,v| [k.to_s, v].flatten }

      chart1 = scatter_chart(worksheet, brd, base_column, 1, 2, data[0].length - 1, 'Temperatures', data_set[:temperature_meta][:label])
      chart2 = scatter_chart(worksheet, brd, base_column, 1, 3, data[0].length - 1, 'Solar', data_set[:solar_meta][:label])
      chart3 = line_chart(   worksheet, brd, base_column, 0, 5, data[0].length - 1, 'Difference from model')

      pct = data_set[:solar_temperature_meta][:sd]
      pct_name = pct.nan? ? 'NaN percent' : "#{(pct * 100).round(0)} percent"
      chart4_name = "Percent diff from model sd = #{pct_name}"
      chart4 = line_chart(   worksheet, brd, base_column, 0, 6, data[0].length - 1, chart4_name)

      meta_location   = sheet_ref_local(worksheet, 0, base_column)
      data_location   = sheet_ref_local(worksheet, brd, base_column)

      chart_location1 = sheet_ref_local(worksheet,  0, base_column)
      chart_location2 = sheet_ref_local(worksheet, 14, base_column)
      chart_location3 = sheet_ref_local(worksheet, 28, base_column)
      chart_location4 = sheet_ref_local(worksheet, 35, base_column)

      worksheet.insert_chart(chart_location1, chart1)
      worksheet.insert_chart(chart_location2, chart2)
      worksheet.insert_chart(chart_location3, chart3)
      worksheet.insert_chart(chart_location4, chart4)
      worksheet.write(data_location, data)
      worksheet.write(meta_location, meta_data_grid)
    end
  end

  def scatter_chart(worksheet, brd, base_column, c1, c2, len, name, label)
    chart = @workbook.add_chart(type: 'scatter', embedded: 1)
    chart.set_legend( :position => 'top' )

    chart.add_series(
        categories:  sheet_ref(worksheet, brd + 1, base_column + c1, brd + len, base_column + c1),
        values:      sheet_ref(worksheet, brd + 1, base_column + c2, brd + len, base_column + c2),
        trendline:    { type: 'linear', display_equation: 1, display_r_squared: 1, name: label }
      )
    chart.set_title(name: name)
    chart
  end

  def line_chart(worksheet, brd, base_column, c1, c2, len, name)
    chart = @workbook.add_chart(type: 'line', embedded: 1)
    chart.set_legend( :position => 'top' )

    chart.add_series(
        categories:  sheet_ref(worksheet, brd + 1, base_column + c1, brd + len, base_column + c1),
        values:      sheet_ref(worksheet, brd + 1, base_column + c2, brd + len, base_column + c2),
      )
    chart.set_title(name: name)
    chart
  end

  def pad(arr, len)
    arr.fill(nil,arr.length,len-arr.length)
  end

  def remove_nan(arr2)
    arr2.map { |r| r.map{ |c| c.is_a?(Float) && c.nan? ? "NAN" : c }}
  end
end

def save_to_csv(results)
  filename = 'Results\electricity seasonal analysis.csv'
  puts "Saving readings to #{filename}"
  CSV.open(filename, 'w') do |csv|
    csv << ['name', 'solar a', 'solar b', 'solar r2', 'temp a', 'temp b', 'temp r2', 'sol temp r2', 'days', 'model sd']
    results.each do |row|
      csv << row
    end
  end
end


school_name_pattern_match = ['*']
source_db = :unvalidated_meter_data # :analytics_db

school_names = RunTests.resolve_school_list(source_db, school_name_pattern_match)
results = []
raw_data = []

excel = ExcelScatterChart.new

school_names.each do |school_name|
  puts "==============================Doing #{school_name} ================================"

  school = SchoolFactory.new.load_or_use_cached_meter_collection(:name, school_name, source_db)
  RubyProf.start if profile

  analyser = AnalyseElectricitySeasonality.new(school)
  summary, raw_data = analyser.analyse(:raw)
  summary, raw_data1 = analyser.analyse(:without_bottom_10_percent)
  summary, raw_data2 = analyser.analyse(:most_recent_300_school_days_without_bottom_10_percent)
  results.push(summary)

  next if summary.nil?

  excel.save([raw_data, raw_data1, raw_data2], school_name[0..14])

  if profile
    prof_result = RubyProf.stop
    printer = RubyProf::GraphHtmlPrinter.new(prof_result)
    printer.print(File.open('log\code-profile - electricity seasonality' + Date.today.to_s + '.html','w')) # 'code-profile.html')
  end
end

excel.close

save_to_csv(results.compact)


