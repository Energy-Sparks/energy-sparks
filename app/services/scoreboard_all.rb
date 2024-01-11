# frozen_string_literal: true

# scoreboard for all schools
class ScoreboardAll
  include Scorable

  SLUG = 'all'

  attr_reader :academic_year_calendar

  def initialize
    @academic_year_calendar = Calendar.find_by(title: 'England and Wales', calendar_type: 'national')
  end

  def schools
    School.where(country: %i[england wales scotland])
  end

  def scored_schools(**kwargs)
    @academic_year_calendar.nil? ? ScoredSchoolsList.new([]) : super(**kwargs).with_points
  end

  def name
    I18n.t('scoreboards.all_title')
  end

  def to_param
    SLUG
  end
end
