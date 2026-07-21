# frozen_string_literal: true

# == Schema Information
#
# Table name: meter_z_installations
#
#  id                      :bigint(8)        not null, primary key
#  active                  :boolean          default(TRUE), not null
#  api_key                 :text             not null
#  meters_list             :jsonb
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  amr_data_feed_config_id :bigint(8)        not null
#
# Indexes
#
#  index_meter_z_installations_on_amr_data_feed_config_id  (amr_data_feed_config_id)
#  index_meter_z_installations_on_api_key                  (api_key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (amr_data_feed_config_id => amr_data_feed_configs.id) ON DELETE => cascade
#
class MeterZInstallation < ApplicationRecord
  belongs_to :amr_data_feed_config

  has_many :meters, dependent: nil
  # has_many :meter_z_installation_schools, dependent: nil
  has_many :schools, through: :meters

  validates :api_key, presence: true

  scope :active, -> { where(active: true) }

  def display_name
    meters_list&.first&.[]('organisation_name') || id
  end

  def create_meter(api_meter_id, school_id)
    Meter.create(meter_serial_number: api_meter_id, school_id:, meter_z_installation_id: id,
                 meter_type: :solar_pv, pseudo: true, active: false,
                 mpan_mprn: generate_mpan(api_meter_id),
                 name: meter_name(api_meter_id))
  end

  def api = DataFeeds::MeterZ.new(api_key)

  def readings(meter_id, start_date)
    data = find_stored_api_data(meter_id)
    return [] if data.nil?

    api.readings(data['organisation_id'], data['site_id'], meter_id, start_date)
  end

  def find_stored_api_data(meter_id) = meters_list&.find { |meter| meter['meter_id'] == meter_id }

  def meter_name(meter_id)
    meter = find_stored_api_data(meter_id)
    "MeterZ - #{meter&.[]('meter_name')} (#{meter&.[]('site_name')})"
  end

  private

  def generate_mpan(meter_id)
    # uuid, truncate to max length our mpan function supports for solar
    Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(meter_id.delete('-').to_i(16).to_s.last(13), :solar_pv)
  end
end
