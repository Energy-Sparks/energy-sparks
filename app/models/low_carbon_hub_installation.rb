# == Schema Information
#
# Table name: low_carbon_hub_installations
#
#  created_at    :datetime         not null
#  id            :bigint(8)        not null, primary key
#  information   :json
#  rbee_meter_id :integer
#  school_id     :bigint(8)        not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_low_carbon_hub_installations_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class LowCarbonHubInstallation < ApplicationRecord
  belongs_to :school, inverse_of: :low_carbon_hub_installations

  has_many :meters

  def school_number
    school.urn
  end

  def electricity_meter
    meters.electricity.first
  end

  def latest_electricity_reading
    Date.parse(electricity_meter.amr_data_feed_readings.order(reading_date: :desc).first.reading_date)
  end
end
