# estimates a meter's solar PV capacity (kWp) and orientation (S = 180o)
# based on analysis of consumption data at weekends, accuracy depends
# on relationship between baseload and array capacity, the larger the
# difference the more the school exports and the less real data the
# analysis can work with, and the less accurate it is. Doesn't
# calculate inclination as emperical analysis led to inconclusive results.
# Has debug which writes to csv files
require 'require_all'

class ExistingSolarPVCapacityEstimator
  include Logging
  MIN_MAINS_CONSUMPTION_FOR_ANALYSIS_KW = 0.1
  MIN_CHANGE_FROM_BASELOAD_KW = -0.25
  MIN_R2_FOR_PV = 0.25
  MIN_PV_YIELD = 0.0
  MIN_PV_kWP = 1.5
  def initialize(school)
    @school = school
    @super_debug = true
  end

  # returns [mpan] => { pv: calculated_pv, orientation: degrees, has_solar_pv: true, false}
  def calculate(calculate_orientation: true, years_offset: 0)
    raise EnergySparksUnexpectedStateException, "years_offset #{years_offset} must be zero or negative" if years_offset > 0
    logger.info "Estimating PV capacity of #{@school.name}: calc oritentation = #{calculate_orientation} years offset = #{years_offset}"
    if @school.low_carbon_solar_pv_panels?
      calculate_low_carbon_hub_school(years_offset: years_offset)
    else
      calculate_synthetic_sheffield_solar_pv_school(years_offset: years_offset)
    end
  end

  # compares LCC production output to Sheffield Uni estimate
  def calculate_low_carbon_hub_school(years_offset: 0)
    prod = []
    shef_pv = []
    times = []
    pv_production = @school.solar_pv_meter.amr_data

    start_date, end_date = date_range_for_meter(@school.solar_pv_meter, years_offset)

    (start_date..end_date).each do |date|
      (0..47).each do |hh_index|
        pv_prod = pv_production.kw(date, hh_index)
        if pv_prod > 0.25
          pv_yield = @school.solar_pv.solar_pv_yield(date, hh_index)
          prod.push(pv_prod)
          shef_pv.push(pv_yield)
          times.push(DateTimeHelper.datetime(date, hh_index))
        end
      end
    end

    x = Daru::Vector.new(prod)
    y = Daru::Vector.new(shef_pv)
    sr = Statsample::Regression.simple(x, y)
    results = { a: sr.a, b: sr.b, pv: 1.0 / sr.b, r2: sr.r2, has_solar_pv: true}

    save_lcc_debug_csv(times, prod, shef_pv) if @super_debug

    results
  end

  private

  def original_electricity_meter(electricity_meter)
    if electricity_meter.sheffield_simulated_solar_pv_panels?
      electricity_meter.sub_meters.find { |sub_meter| sub_meter.name == SolarPVPanels::ELECTRIC_CONSUMED_FROM_MAINS_METER_NAME }
    else
      electricity_meter
    end
  end

  def date_range_for_meter(meter, years_offset)
    end_date = meter.amr_data.end_date + years_offset * 365
    start_date = [end_date - 365, meter.amr_data.start_date].max

    [start_date, end_date]
  end

  def calculate_sheffield_school_meter(electricity_meter, calculate_orientation: true, years_offset: 0)
    mains_consumption_meter = original_electricity_meter(electricity_meter)

    hh_offset_range = calculate_orientation ? -4..4 : 0..0

    results = []
    hh_offset_range.each do |hh_offset|
      begin
        result = estimate_pv_capacity(mains_consumption_meter, hh_offset, years_offset)
        results.push(result)
      rescue StandardError => e
        puts e.message
        puts e.backtrace
      end
    end
    best_fit = results.sort { |a,b| a[:r2] <=> b[:r2] }.last
  end

  def calculate_synthetic_sheffield_solar_pv_school(calculate_orientation: false, years_offset: 0)

    return nil if @school.aggregated_electricity_meters.nil?

    @school.electricity_meters.map do |electricity_meter|
      [electricity_meter.mpan_mprn, calculate_sheffield_school_meter(electricity_meter)]
    end.to_h
  end

  private

  def estimate_pv_capacity(meter, hh_offset = 0, years_offset = 0)
    mains_consumptions_kw = []
    solar_pv_yield_kw = []
    times = []
    baseloads = []

    start_date, end_date = date_range_for_meter(meter, years_offset)

    (start_date..end_date).each do |date|
      if date.saturday? || date.sunday?
        baseload_kw = meter.amr_data.overnight_baseload_kw(date)
        (10..36).each do |hh_index|
          pv_yield = @school.solar_pv.solar_pv_yield(date, hh_index + hh_offset)
          if pv_yield > MIN_PV_YIELD
            mains_consumption_kw = meter.amr_data.kw(date, hh_index)
            next if mains_consumption_kw < MIN_MAINS_CONSUMPTION_FOR_ANALYSIS_KW
            change_from_baseload = mains_consumption_kw - baseload_kw
            if change_from_baseload < MIN_CHANGE_FROM_BASELOAD_KW
              mains_consumptions_kw.push(change_from_baseload)
              solar_pv_yield_kw.push(pv_yield)
              if @super_debug
                times.push(DateTimeHelper.datetime(date, hh_index))
                baseloads.push(baseload_kw)
              end
            end
          end
        end
      end
    end

    return { pv: 0.0, config_pv: 0.0, has_solar_pv: false, hh_offset: hh_offset, r2: 0.0, years_offset: years_offset, n: mains_consumptions_kw.length } if mains_consumptions_kw.length < 10

    result = calculate_result(meter, mains_consumptions_kw, solar_pv_yield_kw, hh_offset, years_offset, start_date, end_date)

    save_debug(times, solar_pv_yield_kw, baseloads, result, mains_consumptions_kw) if @super_debug

    result

  end

  def calculate_result(meter, mains_consumptions_kw, solar_pv_yield_kw, hh_offset, years_offset, start_date, end_date)
    x = Daru::Vector.new(mains_consumptions_kw)
    y = Daru::Vector.new(solar_pv_yield_kw)
    sr = Statsample::Regression.simple(x, y)

    config_kwp = meter.attributes(:solar_pv).nil? ? 0.0 : meter.attributes(:solar_pv)[0][:kwp]

    {
      a:            sr.a,
      b:            sr.b,
      pv:           -1.0 / sr.b,
      has_solar_pv: sr.r2 > MIN_R2_FOR_PV && -1.0 / sr.b > MIN_PV_kWP,
      config_pv:    config_kwp,
      hh_offset:    hh_offset,
      orientation:  orientation(hh_offset),
      r2:           sr.r2,
      years_offset: years_offset,
      n:            mains_consumptions_kw.length,
      start_date:   start_date,
      end_date:     end_date
    }
  end

  def orientation(hh_offset)
    180.0 - hh_offset * 15 # 15 degrees per half hour
  end

  def save_debug(times, solar_pv_yield_kw, baseloads, result, mains_consumptions_kw)
    deviation_from_model = []
    solar_pv_yield_kw.each_with_index do |pv_yield, index|
      deviation_from_model.push(baseloads[index] - pv_yield * result[:pv])
    end
    save_to_csv(times, mains_consumptions_kw, solar_pv_yield_kw, deviation_from_model, result[:hh_offset], result[:years_offset])
  end

  def save_to_csv(times, change_from_baseload, pv_yield, deviation_from_model, hh_offset, years_offset)
    filename = "Results\\solar PV estimator #{hh_offset} #{years_offset} #{@school.name}.csv"
    logger.info "Saving readings to #{filename}"
    CSV.open(filename, 'w') do |csv|
      csv << ['datetime', 'change from baseload', 'pv_yield', 'deviation from model']
      times.each_with_index do |dt, index|
        csv << [dt, change_from_baseload[index], pv_yield[index], deviation_from_model[index]]
      end
    end
  end

  def save_lcc_debug_csv(times, prod, shef_pv)
    filename = "Results\\lcc solar PV estimator #{@school.name}.csv"
    logger.info "Saving readings to #{filename}"
    CSV.open(filename, 'w') do |csv|
      csv << ['datetime', 'pv', 'yield']
      times.each_with_index do |dt, index|
        csv << [dt, prod[index], shef_pv[index]]
      end
    end
  end
end
