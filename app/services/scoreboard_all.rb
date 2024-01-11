# frozen_string_literal: true

# scoreboard for all schools
class ScoreboardAll
  include Scorable

  SLUG = 'all'

  # attr_reader :academic_year_calendar

  # def initialize
  #   @academic_year_calendar = Calendar.new(title: 'National Scoreboard', calendar_type: 'national')
  #   current = AcademicYear.current
  #   @academic_year_calendar.academic_years.build(start_date: "#{current.start_date.year}-09-01",
  #                                                end_date: "#{current.end_date.year}-06-30")
  #   # binding.pry
  # end

  def schools
    School.where(country: %i[england wales scotland])
  end

  def scored_schools(**kwargs)
    # @academic_year_calendar.nil? ? ScoredSchoolsList.new([]) :
    super(**kwargs).with_points
  end

  def name
    I18n.t('scoreboards.all_title')
  end

  def to_param
    SLUG
  end

  def this_academic_year(today: Time.zone.today)
    start_year = today.year - (today.month < 9 ? 1 : 0)
    Struct.new(:start_date, :end_date).new(Date.new(start_year, 9, 1), Date.new(start_year + 1, 6, 30))
  end

  def previous_academic_year(today: Time.zone.today)
    this_academic_year(today: today - 1.year)
  end
end
