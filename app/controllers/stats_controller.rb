class StatsController < ApplicationController
  skip_before_action :authenticate_user!

  # GET /schools/:id/daily_usage_chart?supply=:supply&to_date=:to_date
  def daily_usage
    this_week = school.daily_usage(
      supply,
      to_date - 6.days..to_date,
      '%a %d/%m/%y'
    )
    previous_week = school.daily_usage(
      supply,
      to_date - 13.days..to_date - 7.days
    )
    previous_week_series = previous_week.map.with_index do |day, index|
      # this week's dates with previous week's usage
      [this_week[index][0], day[1]]
    end
    render json: [
      { name: 'Usage', data: this_week },
      { name: 'Previous week', data: previous_week_series }
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
end
