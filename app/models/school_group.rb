# == Schema Information
#
# Table name: school_groups
#
#  created_at    :datetime         not null
#  description   :string
#  id            :bigint(8)        not null, primary key
#  name          :string           not null
#  scoreboard_id :bigint(8)
#  slug          :string           not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_school_groups_on_scoreboard_id  (scoreboard_id)
#
# Foreign Keys
#
#  fk_rails_...  (scoreboard_id => scoreboards.id)
#

class SchoolGroup < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: [:finders, :slugged, :history]

  has_many :schools
  belongs_to :scoreboard

  validates :name, presence: true

  def safe_destroy
    raise EnergySparks::SafeDestroyError, 'Group has associated schools' if schools.any?
    destroy
  end
end
