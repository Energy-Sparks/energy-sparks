# == Schema Information
#
# Table name: observations
#
#  at          :datetime         not null
#  created_at  :datetime         not null
#  description :text
#  id          :bigint(8)        not null, primary key
#  school_id   :bigint(8)        not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_observations_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#


class Observation < ApplicationRecord
  belongs_to :school
  has_many   :temperature_recordings

  validates_presence_of :description, :at

  accepts_nested_attributes_for :temperature_recordings, reject_if: proc {|attributes| attributes['centigrade'].blank? }
end
