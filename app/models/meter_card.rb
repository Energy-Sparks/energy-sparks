# frozen_string_literal: true

class MeterCard
  class Values
    attr_reader :latest_reading_date, :window_first_date, :average_usage, :most_usage

    def initialize(latest_reading_date:, window_first_date:, average_usage:, most_usage:)
      @latest_reading_date = latest_reading_date
      @window_first_date = window_first_date
      @average_usage = average_usage
      @most_usage = most_usage
    end
  end

  attr_reader :supply, :values
  def initialize(supply:, has_readings: false, values: nil)
    @supply = supply
    @has_readings = has_readings
    @values = values
  end

  def has_readings?
    @has_readings
  end

  def has_values?
    @values.present?
  end

  class << self
    def create(school:, supply:, window: 7)
      if (latest_reading_date = school.last_reading_date(supply))
        begin
          new(
            supply: supply,
            has_readings: true,
            values: Values.new(
              latest_reading_date: latest_reading_date,
              window_first_date: latest_reading_date - window.days,
              average_usage: calulate_average_usage(school: school, supply: supply, window: window).to_i,
              most_usage: school.day_most_usage(supply, window)[0]
            )
          )
        rescue => e
          Rollbar.error(e)
          new(supply: supply, has_readings: true)
        end
      else
        new(supply: supply, has_readings: false)
      end
    end

    def calulate_average_usage(school:, supply:, window:)
      last_n_days = school.last_n_days_with_readings(supply, window)
      school.daily_usage(supply: supply, dates: last_n_days).inject(0) { |a, e| a + e[1] } / window
    end
  end
end
