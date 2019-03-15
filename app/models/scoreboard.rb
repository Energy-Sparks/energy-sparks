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
end
