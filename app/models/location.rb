# == Schema Information
#
# Table name: locations
#
#  created_at :datetime         not null
#  id         :bigint(8)        not null, primary key
#  name       :text             not null
#  school_id  :bigint(8)        not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_locations_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class Location < ApplicationRecord
  belongs_to :school
  has_many   :temperature_recordings

  validates :name, presence: true
end
