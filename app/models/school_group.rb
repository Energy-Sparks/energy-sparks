# == Schema Information
#
# Table name: school_groups
#
#  created_at    :datetime         not null
#  description   :string
#  id            :bigint(8)        not null, primary key
#  name          :string           not null
#  scoreboard_id :bigint(8)
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
  has_many :schools

  validates :name, presence: true
end
