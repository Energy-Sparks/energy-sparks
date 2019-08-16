# == Schema Information
#
# Table name: scoreboards
#
#  calendar_area_id :bigint(8)
#  created_at       :datetime         not null
#  description      :string
#  id               :bigint(8)        not null, primary key
#  name             :string           not null
#  slug             :string           not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_scoreboards_on_calendar_area_id  (calendar_area_id)
#
# Foreign Keys
#
#  fk_rails_...  (calendar_area_id => calendar_areas.id) ON DELETE => restrict
#

class Scoreboard < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: [:finders, :slugged, :history]

  has_many :school_groups
  has_many :schools, through: :school_groups
  belongs_to :calendar_area

  validates :name, :calendar_area_id, presence: true

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Scoreboard has associated groups' if school_groups.any?
    destroy
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def scored_schools(recent_boundary: 1.month.ago)
    schools.active.select('schools.*, SUM(observations.points) AS sum_points, SUM(recent_observations.points) AS recent_points').
      joins('LEFT JOIN observations ON observations.school_id = schools.id').
      joins(self.class.sanitize_sql_array(['LEFT OUTER JOIN observations AS recent_observations ON recent_observations.school_id = schools.id AND recent_observations.at > ?', recent_boundary])).
      order(Arel.sql('sum_points DESC NULLS LAST, MAX(observations.at) DESC, schools.name ASC')).
      group('schools.id')
  end

  def position(school)
    scored_schools.index(school)
  end
end
