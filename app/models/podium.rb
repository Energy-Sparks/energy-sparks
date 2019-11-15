class Podium
  class Position
    attr_reader :school, :points, :position, :normalised_points
    def initialize(school:, points:, position:, normalised_points:, recent_points:)
      @school = school
      @points = points
      @position = position
      @normalised_points = normalised_points
      @recent_points = recent_points
    end

    def ordinal
      "#{@position}#{@position.ordinal}"
    end

    def recent_points
      @recent_points || 0
    end
  end

  def self.create(scoreboard:, school:, recent_boundary: 1.month.ago)
    scored_schools = scoreboard.scored_schools(recent_boundary: recent_boundary)
    schools_with_points = scored_schools.with_points
    school_index = schools_with_points.index(school)

    final = if schools_with_points.size > 3
              schools_with_points.schools_at(starting_index(school_index, schools_with_points), 3).compact
            else
              schools_with_points
            end

    normalised_points = EnergySparks::PointsDisplayNormaliser.normalise(final.map(&:sum_points))
    positions = final.zip(normalised_points).map do |scored_school, normalised_point|
      Position.new(
        school: scored_school,
        points: scored_school.sum_points,
        position: schools_with_points.position(scored_school),
        normalised_points: normalised_point,
        recent_points: scored_school.recent_points
      )
    end
    new(scoreboard: scoreboard, school: school, positions: positions)
  end

  def self.starting_index(school_index, scored_schools)
    last_place = (scored_schools.size - 1)
    first_place = 0
    if school_index == first_place
      0
    elsif school_index.nil? || school_index == last_place
      -3
    else
      school_index - 1
    end
  end

  attr_reader :scoreboard

  def initialize(scoreboard:, school:, positions: [])
    @scoreboard = scoreboard
    @positions = positions
    @school = school
  end

  def high_to_low
    @positions
  end

  def low_to_high
    high_to_low.reverse
  end

  def includes_school?
    school_position.present?
  end

  def school_position
    @positions.find {|position| position.school == @school}
  end

  def current_school?(position)
    position.school == @school
  end
end
