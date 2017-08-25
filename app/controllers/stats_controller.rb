class StatsController < ApplicationController
  include ActionView::Helpers::NumberHelper

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

  #CURRENT
  #compare hourly usage across two dates
  # GET /schools/:id/compare_hourly_usage?comparison=type&supply=:supply&meter=:meter_no&first_date=:first_date&to_date=:second_date&second_meter=meter_no
  def compare_hourly_usage
    precision = lambda { |reading| [reading[0], number_with_precision(reading[1], precision: 1)] }
    if comparison == "whole-school"
      from = first_date
      to = to_date
      first_date = school.hourly_usage_for_date(supply: supply,
          date: from,
          meter: meter,
          scale: :kw
      ).map(&precision)
      to_date = school.hourly_usage_for_date(supply: supply,
          date: to,
          meter: meter,
          scale: :kw
      ).map(&precision) unless to.nil?
      data = [ { name: from.strftime('%A, %d %B %Y'), data: first_date } ]
      data << { name: to.strftime('%A, %d %B %Y'), data: to_date } unless to.nil?
    else
      from = first_date()
      first_meter = school.hourly_usage_for_date(supply: supply,
        date: from,
        meter: meter,
        scale: :kw
      ).map(&precision)

      second_m = school.hourly_usage_for_date(supply: supply,
        date: from,
        meter: second_meter,
        scale: :kw
      ).map(&precision) unless second_meter.nil?
      data = [ { name: from.strftime('%A, %d %B %Y'), data: first_meter } ]
      data << { name: from.strftime('%A, %d %B %Y'), data: second_m } unless second_meter.nil?
    end
    render json: data
  end

  # GET /schools/:id/hourly_usage?supply=:supply&to_date=:to_date&meter=:meter_no
  # compares hourly usage by weekday/weekend for last full week
  def hourly_usage
    week = Usage.this_week(to_date).to_a
    precision = lambda { |reading| [reading[0], number_with_precision(reading[1], precision: 1)] }
    weekend = school.hourly_usage(
      supply: supply,
      dates: week[0]..week[1],
      meter: meter
    ).map(&precision)
    weekday = school.hourly_usage(
      supply: supply,
      dates: week[2]..week[6],
      meter: meter
    ).map(&precision)
    render json: [
      { name: 'Weekday', data: weekday },
      { name: 'Weekend', data: weekend }
    ]
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
    Date.parse(params[:to_date])
  rescue
    nil
  end

  def comparison
    params[:comparison] || "whole-school"
  end

end
