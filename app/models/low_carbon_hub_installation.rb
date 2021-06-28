# == Schema Information
#
# Table name: low_carbon_hub_installations
#
#  amr_data_feed_config_id :bigint(8)        not null
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  information             :json
#  password                :string
#  rbee_meter_id           :text
#  school_id               :bigint(8)        not null
#  updated_at              :datetime         not null
#  username                :string
#
# Indexes
#
#  index_low_carbon_hub_installations_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#  index_low_carbon_hub_installations_on_school_id                (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_config_id => amr_data_feed_configs.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#

class LowCarbonHubInstallation < ApplicationRecord
  belongs_to :school, inverse_of: :low_carbon_hub_installations
  belongs_to :amr_data_feed_config

  has_many :meters

  validates_presence_of :rbee_meter_id

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
