# == Schema Information
#
# Table name: scoreboards
#
#  academic_year_calendar_id :bigint(8)
#  created_at                :datetime         not null
#  description               :string
#  id                        :bigint(8)        not null, primary key
#  name                      :string           not null
#  public                    :boolean          default(TRUE)
#  slug                      :string           not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_scoreboards_on_academic_year_calendar_id  (academic_year_calendar_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_calendar_id => calendars.id) ON DELETE => nullify
#

class Scoreboard < ApplicationRecord
  extend FriendlyId

  scope :is_public, -> { where(public: true) }

  FIRST_YEAR = 2018

  friendly_id :name, use: [:finders, :slugged, :history]

  has_many :schools
  belongs_to :academic_year_calendar, class_name: 'Calendar', optional: true

  validates :name, :academic_year_calendar_id, presence: true

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Scoreboard has associated schools' if schools.any?
    destroy
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def active_academic_years(today: Time.zone.today)
    academic_year_calendar.academic_years.where("date_part('year', start_date) >= ? AND start_date <= ?", FIRST_YEAR, today).order(:start_date)
  end

  def scored_schools(recent_boundary: 1.month.ago, academic_year: this_academic_year)
    scored = schools.visible.select('schools.*, SUM(observations.points) AS sum_points, MAX(observations.at) AS recent_observation').select(
      self.class.sanitize_sql_array(
        ['SUM(observations.points) FILTER (WHERE observations.at > ?) AS recent_points', recent_boundary]
      )
    ).
      order(Arel.sql('sum_points DESC NULLS LAST, MAX(observations.at) DESC, schools.name ASC')).
      group('schools.id')
    if academic_year
      with_academic_year = scored.joins(
        self.class.sanitize_sql_array(
          ['LEFT JOIN observations ON observations.school_id = schools.id AND observations.at BETWEEN ? AND ?', academic_year.start_date, academic_year.end_date]
        )
      )
      ScoredSchoolsList.new(with_academic_year)
    else
      ScoredSchoolsList.new(scored.left_outer_joins(:observations))
    end
  end

  private

  def this_academic_year
    academic_year_calendar.academic_year_for(Time.zone.today)
  end
end
