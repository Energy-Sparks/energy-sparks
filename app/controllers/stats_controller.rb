class StatsController < ApplicationController
  include ActionView::Helpers::NumberHelper
  include SchoolsHelper
  skip_before_action :authenticate_user!

  # GET /schools/:id/daily_usage?supply=:supply&to_date=:to_date&meter=:meter_no
  def daily_usage
    precision = lambda { |reading| [reading[0], number_with_precision(reading[1], precision: 1)] }
    this_week = school.daily_usage(
      supply: supply,
      dates: to_date - 6.days..to_date,
      date_format: '%A',
      meter: meter
    ).map(&precision)
    previous_week = school.daily_usage(
      supply: supply,
      dates: to_date - 13.days..to_date - 7.days,
      meter: meter
    ).map(&precision)
    previous_week_series = previous_week.map.with_index do |day, index|
      # this week's dates with previous week's usage
      [this_week[index][0], day[1]]
    end
    render json: [
      { name: 'Latest 7 days', data: this_week },
      { name: 'Previous 7 days', data: previous_week_series }
    ]
  end

  #compare hourly usage across two dates
  # GET /schools/:id/compare_hourly_usage?comparison=type&supply=:supply&meter=:meter_no&first_date=:first_date&to_date=:second_date&second_meter=meter_no
  def compare_hourly_usage
    precision = lambda { |reading| [reading[0], number_with_precision(reading[1], precision: 1)] }
    from = first_date
    data = []
    if comparison == "whole-school"
      first_series = hourly_usage_to_precision(school, supply, from, meter)
      data << { name: from.strftime('%A, %d %B %Y'), color: colours_for_supply(supply)[0], data: first_series }
      if to_date.present?
        second_series = hourly_usage_to_precision(school, supply, to_date, meter)
        data << { name: to_date.strftime('%A, %d %B %Y'), color: colours_for_supply(supply)[1], data: second_series }
      end
    else
      first_series = hourly_usage_to_precision(school, supply, from, meter)
      data << { name: meter + " " + from.strftime('%A, %d %B %Y'), color: colours_for_supply(supply)[0], data: first_series }
      if second_meter.present?
        second_series = hourly_usage_to_precision(school, supply, from, second_meter)
        data << { name: second_meter + " " + from.strftime('%A, %d %B %Y'), color: colours_for_supply(supply)[1], data: second_series } unless second_series.nil?
      end
    end
    render json: data
  end

private


  # Use callbacks to share common setup or constraints between actions.
  def school
    School.find(params[:id])
  end

  def meter
    params[:first_meter]
  end

  def second_meter
    params[:second_meter].present? ? params[:second_meter] : nil
  end

  def supply
    params[:supply]
  end

  def first_date
    Date.parse(params[:first_date])
  end

  def to_date
    return nil unless params[:to_date].present?
    Date.parse(params[:to_date])
  rescue
    nil
  end

  def comparison
    params[:comparison] || "whole-school"
  end
end
