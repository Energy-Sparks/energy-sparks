class SolarEdgeInstallation < ApplicationRecord
  belongs_to :school, inverse_of: :low_carbon_hub_installations
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
