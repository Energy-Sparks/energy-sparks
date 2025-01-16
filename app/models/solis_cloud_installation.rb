# == Schema Information
#
# Table name: solis_cloud_installations
#
#  amr_data_feed_config_id :bigint(8)        not null
#  api_id                  :text
#  api_secret              :text
#  created_at              :datetime         not null
#  id                      :bigint(8)        not null, primary key
#  school_id               :bigint(8)        not null
#  station_list            :jsonb
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_solis_cloud_installations_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#  index_solis_cloud_installations_on_school_id                (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_config_id => amr_data_feed_configs.id) ON DELETE => cascade
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class SolisCloudInstallation < ApplicationRecord
  belongs_to :school, inverse_of: :solar_edge_installations
  belongs_to :amr_data_feed_config

  has_many :meters, dependent: nil

  validates :api_id, :api_secret, presence: true

  def display_name
    "Solis Cloud Installation #{id}"
  end

  def latest_electricity_reading
    AmrDataFeedReading.where(meter_id: meters).maximum(:reading_date)
  end
end
