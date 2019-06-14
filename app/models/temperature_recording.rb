# == Schema Information
#
# Table name: temperature_recordings
#
#  centigrade     :decimal(, )      not null
#  created_at     :datetime         not null
#  id             :bigint(8)        not null, primary key
#  location_id    :bigint(8)        not null
#  observation_id :bigint(8)        not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_temperature_recordings_on_location_id     (location_id)
#  index_temperature_recordings_on_observation_id  (observation_id)
#
# Foreign Keys
#
#  fk_rails_...  (location_id => locations.id) ON DELETE => cascade
#  fk_rails_...  (observation_id => observations.id) ON DELETE => cascade
#


class TemperatureRecording < ApplicationRecord
  belongs_to :observation
  belongs_to :location

  validates_presence_of :centigrade, :location
  validates_numericality_of :centigrade, greater_than: 0, less_than: 50
  validates_associated :location

  accepts_nested_attributes_for :location
end
