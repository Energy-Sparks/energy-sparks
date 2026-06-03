class BivariateSolarTemperatureModel
  def initialize(amr_data, temperatures, solar_irradiation, holidays, open_time: nil, close_time: nil)
    @amr_data = amr_data
    @temperatures = temperatures
    @solar_irradiation = solar_irradiation
    @holidays = holidays
    @open_times_x48 = opening_times_vector_x48(open_time, close_time)
  end

  def fit(include_dates_or_ranges, exclude_dates_or_ranges: [], day_type: :all_day_types)
    dates = convert_to_dates(include_dates_or_ranges, exclude_dates_or_ranges)

    raw_data = dates.map do |date|
      (day_type ==  :all_day_types || @holidays.day_type(date) == day_type) ? data(date) : nil
    end.compact.transpose

    model = BivariateModel.new(day_type, raw_data[0], raw_data[1], raw_data[2], @open_times_x48)
    model.calculate
    model
  end

  private

  class BivariateModel
    class BivariateModelCalculationFailed < StandardError; end
    def initialize(name, kwhs, degree_days, solar_irradiance, open_times_x48)
      @name             = name
      @kwhs             = kwhs
      @degree_days      = degree_days
      @solar_irradiance = solar_irradiance
      @open_times_x48   = open_times_x48
    end

    def calculate
      calculate_bivariate_regression
    end

    def interpolate(degree_days, solar_irradiance_x48)
      solar = AMRData.fast_multiply_x48_x_x48(solar_irradiance_x48, @open_times_x48).sum
      @model_results[:insolation_coeff] * solar + @model_results[:degreeday_coeff] * degree_days + @model_results[:constant]
    end

    def to_s
      "solar degree day regression model: #{@name}:"\
      " #{@model_results[:insolation_coeff].round(3)} * sol +"\
      " #{@model_results[:degreeday_coeff].round(3)} * dd +"\
      " #{@model_results[:constant].round(3)} : "\
      "R2 = #{@model_results[:r2].round(2)}, "\
      "N = #{@model_results[:samples]}"\
      " in #{@model_results[:calculation_time].round(3)} s"
    end

    private

    def calculate_bivariate_regression
      bm = Benchmark.realtime {
        x1 = Daru::Vector.new(@degree_days)
        x2 = Daru::Vector.new(@solar_irradiance)
        y = Daru::Vector.new(@kwhs)
        ds = Daru::DataFrame.new({:heating_dd => x1, :lighting_ir => x2, :kwh => y})
        lr = Statsample::Regression.multiple(ds, :kwh)
        @model_results = {
          r2:               lr.r2,
          insolation_coeff: lr.coeffs[:lighting_ir],
          degreeday_coeff:  lr.coeffs[:heating_dd],
          constant:         lr.constant,
          samples:          @kwhs.length
        }
      }

      @model_results.merge!({calculation_time: bm})

      @model_results
    rescue Statsample::Regression::LinearDependency => _x
      raise BivariateModelCalculationFailed, "Linear dependence error in statsample"
    rescue NoMethodError => x
      raise BivariateModelCalculationFailed, "nil method failure"
    end
  end

  def data(date)
    # for dcc and other up to date meters, amr_data goes to yesterday, but solar only to the day before
    return nil unless @solar_irradiation.date_exists?(date)

    [
      AMRData.fast_multiply_x48_x_x48(@amr_data.days_kwh_x48(date), @open_times_x48).sum,
      @temperatures.degree_days(date),
      AMRData.fast_multiply_x48_x_x48(@solar_irradiation.one_days_data_x48(date), @open_times_x48).sum
    ]
  end

  def opening_times_vector_x48(open_time, close_time)
    return Array.new(48, 1.0) if open_time.nil? || close_time.nil?

    DateTimeHelper.weighted_x48_vector_multiple_ranges([open_time..close_time])
  end

  def convert_to_dates(include_dates_or_ranges, exclude_dates_or_ranges)
    included = convert_dates_and_ranges_to_dates(include_dates_or_ranges)
    excluded = convert_dates_and_ranges_to_dates(exclude_dates_or_ranges)
    excluded.each do |date|
      included.delete(date)
    end
    included.sort
  end

  def convert_dates_and_ranges_to_dates(dates_or_ranges)
    dates_or_ranges = [dates_or_ranges] unless dates_or_ranges.is_a?(Array)
    updated_dates_or_ranges = []

    dates_or_ranges.each do |date_or_range|
      if date_or_range.is_a?(Date)
        updated_dates_or_ranges.push(date_or_range)
      elsif date_or_range.is_a?(Range)
        updated_dates_or_ranges += date_or_range.to_a
      else
        raise EnergySparksUnexpectedStateException, "Unexpected date or date range #{date_or_range.class.name}"
      end
    end

    updated_dates_or_ranges
  end
end
