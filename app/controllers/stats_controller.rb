class StatsController < ApplicationController
  skip_before_action :authenticate_user!

  # GET /schools/:id/daily_usage_chart?supply=:supply&to_date=:to_date
  def daily_usage
    this_week = get_daily_readings(
      (to_date - 6.days).beginning_of_day..to_date.end_of_day
    )
    previous_usage = get_daily_readings(
      (to_date - 13.days).beginning_of_day..(to_date - 7.days).end_of_day
    )
    previous_week = previous_usage.map.with_index do |day, index|
      # this week's dates with previous week's usage
      [this_week[index][0], day[1]]
    end
    render json: [
      { name: 'Usage', data: this_week },
      { name: 'Previous week', data: previous_week }
    ]
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def school
    School.find(params[:id])
  end

  def supply
    params[:supply]
  end

  def to_date
    Date.parse(params[:to_date])
  rescue
    Date.current
  end

  def get_daily_readings(dates)
    school.meter_readings
          .where('meters.meter_type = ?', Meter.meter_types[supply])
          .group_by_day(:read_at, range: dates, format: "%d/%m/%y")
          .sum(:value)
          .to_a
  end
end
