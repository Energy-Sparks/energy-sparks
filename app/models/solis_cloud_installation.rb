# == Schema Information
#
# Table name: solis_cloud_installations
#
#  amr_data_feed_config_id :bigint(8)        not null
#  api_id                  :text
#  api_secret              :text
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  inverter_detail_list    :jsonb
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_solis_cloud_installations_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_config_id => amr_data_feed_configs.id) ON DELETE => cascade
#
class SolisCloudInstallation < ApplicationRecord
  belongs_to :amr_data_feed_config

  has_many :meters, dependent: nil
  has_many :solis_cloud_installation_schools, dependent: nil
  has_many :schools, through: :solis_cloud_installation_schools

  validates :api_id, :api_secret, presence: true

  def self.mpan(serial_number)
    # serial number in api response appear to be hex, truncate to max length our mpan function supports for solar
    Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(serial_number.to_i(16).to_s.last(13), :solar_pv)
  end

  def display_name
    api_id
  end

  def api
    DataFeeds::SolisCloudApi.new(api_id, api_secret)
  end

  def update_inverter_detail_list
    inverter_detail_list = api.inverter_detail_list.dig('data', 'records') || []
    update!(inverter_detail_list:)
    inverter_detail_list
  end

  def create_meter(meter_serial_number, school_id)
    Meter.create(meter_serial_number:, school_id:, solis_cloud_installation_id: id,
                 meter_type: :solar_pv, pseudo: true, active: false,
                 mpan_mprn: self.class.mpan(meter_serial_number),
                 name: meter_name(meter_serial_number))
  end

  def meter_name(serial)
    inverter = inverter_detail_list.find { |inverter| inverter['sn'] == serial }
    name = "#{[inverter['name'], inverter['stationName']].compact.join(' / ')} (#{inverter['sno']})" if inverter
    "SolisCloud - #{name || serial}"
  end
end
