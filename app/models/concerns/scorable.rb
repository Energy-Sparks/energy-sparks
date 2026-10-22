module Scorable
  extend ActiveSupport::Concern

  def national?
    is_a? NationalScoreboard
  end

  def this_academic_year(today: Time.zone.today)
    scorable_calendar.academic_year_for(today)
  end

  def previous_academic_year(today: Time.zone.today)
    scorable_calendar.academic_year_for(today).previous_year
  end

  # Calendar to be used for finding academic years. Overridden by groups
  def scorable_calendar
    academic_year_calendar
  end

  def scored_schools(recent_boundary: 1.month.ago, academic_year: this_academic_year)
    if academic_year
      ScoredSchoolsList.new(scored(recent_boundary: recent_boundary).joins(observations_in_period(academic_year)))
    else
      ScoredSchoolsList.new(scored(recent_boundary: recent_boundary).left_outer_joins(:observations))
    end
  end

  def top_scoring_school(period:)
    scored.joins(observations_in_period(period)).having('SUM(observations.points) > 0').first
  end

  def scored(recent_boundary: 1.month.ago)
    scorable_schools.visible.select('schools.*, SUM(observations.points) AS sum_points, MAX(observations.at) AS recent_observation').select(
      ActiveRecord::Base.sanitize_sql_array(
        ['SUM(observations.points) FILTER (WHERE observations.at > ?) AS recent_points', recent_boundary]
      )
    ).
      order(Arel.sql('sum_points DESC NULLS LAST, MAX(observations.at) DESC, schools.name ASC')).
      group('schools.id')
  end

  def scorable_schools
    schools
  end

  private

  def observations_in_period(period)
    start_date, end_date = period_dates(period)

    ActiveRecord::Base.sanitize_sql_array(
      [
        'LEFT JOIN observations ON observations.school_id = schools.id AND observations.at BETWEEN ? AND ?',
        start_date, end_date
      ]
    )
  end

  def period_dates(period)
    period.is_a?(Range) ? [period.begin, period.end] : [period.start_date, period.end_date]
  end
end
