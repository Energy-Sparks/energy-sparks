# == Schema Information
#
# Table name: observations
#
#  at               :datetime         not null
#  created_at       :datetime         not null
#  description      :text
#  id               :bigint(8)        not null, primary key
#  observation_type :integer          not null
#  school_id        :bigint(8)        not null
#  updated_at       :datetime         not null
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

  enum observation_type: [:temperature, :intervention]

  validates_presence_of :at, :school
  validate :at_date_cannot_be_in_the_future
  validates_associated :temperature_recordings

  accepts_nested_attributes_for :temperature_recordings, reject_if: :reject_temperature_recordings_and_locations

  def at_date_cannot_be_in_the_future
    errors.add(:at, "Can't be in the future") if at.present? && at > Time.zone.today.end_of_day
  end

private

  def reject_temperature_recordings_and_locations(attributes)
    (attributes['centigrade'].blank? && attributes.dig('location_attributes', 'name').blank?)
  end
end
