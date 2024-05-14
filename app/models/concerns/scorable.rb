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
      with_academic_year = scored(recent_boundary: recent_boundary).joins(
        ActiveRecord::Base.sanitize_sql_array(
          ['LEFT JOIN observations ON observations.school_id = schools.id AND observations.at BETWEEN ? AND ?', academic_year.start_date, academic_year.end_date]
        )
      )
      ScoredSchoolsList.new(with_academic_year)
    else
      ScoredSchoolsList.new(scored(recent_boundary: recent_boundary).left_outer_joins(:observations))
    end
  end

  def scored(recent_boundary: 1.month.ago)
    schools.visible.select('schools.*, SUM(observations.points) AS sum_points, MAX(observations.at) AS recent_observation').select(
      ActiveRecord::Base.sanitize_sql_array(
        ['SUM(observations.points) FILTER (WHERE observations.at > ?) AS recent_points', recent_boundary]
      )
    ).
      order(Arel.sql('sum_points DESC NULLS LAST, MAX(observations.at) DESC, schools.name ASC')).
      group('schools.id')
  end
end
