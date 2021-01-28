# == Schema Information
#
# Table name: solar_edge_installations
#
#  amr_data_feed_config_id :bigint(8)        not null
#  api_key                 :text
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  information             :json
#  mpan                    :text
#  school_id               :bigint(8)        not null
#  site_id                 :text
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_solar_edge_installations_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#  index_solar_edge_installations_on_school_id                (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_config_id => amr_data_feed_configs.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class SolarEdgeInstallation < ApplicationRecord
  belongs_to :school, inverse_of: :solar_edge_installations
  belongs_to :amr_data_feed_config

  has_many :meters

  validates_presence_of :site_id, :mpan, :api_key

  def school_number
    school.urn
  end

  def electricity_meter
    meters.electricity.first if meters.electricity.present?
  end

  def latest_electricity_reading
    if electricity_meter && electricity_meter.amr_data_feed_readings
      Date.parse(electricity_meter.amr_data_feed_readings.order(reading_date: :desc).first.reading_date)
    end
  end
end
