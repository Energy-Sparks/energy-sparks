module Scorable
  extend ActiveSupport::Concern

  def scored(recent_boundary: 1.month.ago)
    schools.visible.select('schools.*, SUM(observations.points) AS sum_points, MAX(observations.at) AS recent_observation').select(
      self.class.sanitize_sql_array(
        ['SUM(observations.points) FILTER (WHERE observations.at > ?) AS recent_points', recent_boundary]
      )
    ).
      order(Arel.sql('sum_points DESC NULLS LAST, MAX(observations.at) DESC, schools.name ASC')).
      group('schools.id')
  end
end
