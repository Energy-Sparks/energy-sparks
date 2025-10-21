# frozen_string_literal: true

class NationalScoreboard
  include Scorable

  SLUG = 'national'

  def schools
    School.all
  end

  def scored_schools(**kwargs)
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
