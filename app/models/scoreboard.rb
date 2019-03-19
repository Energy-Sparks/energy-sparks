# == Schema Information
#
# Table name: scoreboards
#
#  created_at  :datetime         not null
#  description :string
#  id          :bigint(8)        not null, primary key
#  name        :string           not null
#  slug        :string           not null
#  updated_at  :datetime         not null
#

class Scoreboard < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: [:finders, :slugged, :history]

  has_many :school_groups
  has_many :schools, through: :school_groups

  validates :name, presence: true

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Scoreboard has associated groups' if school_groups.any?
    destroy
  end

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def scored_schools
    schools.active.select('schools.*, SUM(num_points) AS sum_points')
        .joins('left join merit_scores ON merit_scores.sash_id = schools.sash_id')
        .joins('left join merit_score_points ON merit_score_points.score_id = merit_scores.id')
        .order('sum_points DESC NULLS LAST')
        .group('schools.id, merit_scores.sash_id')
  end

  def position(school)
    scored_schools.index(school)
  end

  # NOTE: this returns schools [HIGH -> LOW] to
  # matcth the result of score_schools
  # even if the UI requires them the other way round
  def surrounding_schools(school)
    school_position = position(school)
    scored = scored_schools.to_a
    return scored if scored.size < 4
    starting_position = if school_position == 0
                          0
                        elsif school_position == (scored.size - 1)
                          -3
                        else
                          school_position - 1
                        end
    scored[starting_position, 3].compact
  end
end
