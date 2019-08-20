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
    scored_schools = scoreboard.scored_schools(recent_boundary: recent_boundary).reject {|scored_school| scored_school.sum_points.nil? || scored_school.sum_points <= 0}
    school_position = scored_schools.index(school)

    final = if scored_schools.size > 3
              scored_schools[starting_position(school_position, scored_schools), 3].compact
            else
              scored_schools
            end

    normalised_points = EnergySparks::PointsDisplayNormaliser.normalise(final.map(&:sum_points))
    positions = final.zip(normalised_points).map do |scored_school, normalised_point|
      Position.new(
        school: scored_school,
        points: scored_school.sum_points,
        position: scored_schools.index(scored_school) + 1,
        normalised_points: normalised_point,
        recent_points: scored_school.recent_points
      )
    end
    new(scoreboard: scoreboard, school: school, positions: positions)
  end

  def self.starting_position(school_position, scored_schools)
    last_place = (scored_schools.size - 1)
    first_place = 0
    if school_position == first_place
      0
    elsif school_position.nil? || school_position == last_place
      -3
    else
      school_position - 1
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
