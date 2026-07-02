# frozen_string_literal: true

# == Schema Information
#
# Table name: solar_edge_installations
#
#  id                      :bigint(8)        not null, primary key
#  active                  :boolean          default(TRUE), not null
#  api_key                 :text
#  information             :json
#  mpan                    :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  amr_data_feed_config_id :bigint(8)        not null
#  school_id               :bigint(8)        not null
#  site_id                 :text
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

  has_many :meters, dependent: nil

  validates :site_id, :mpan, :api_key, presence: true
  validate :site_id_unique_to_school

  scope :active, -> { where(active: true) }

  def display_name
    site_id
  end

  def school_number
    school.urn
  end

  def electricity_meter
    meters.electricity.presence&.first
  end

  def latest_electricity_reading
    return unless electricity_meter&.amr_data_feed_readings&.any?

    Date.parse(electricity_meter.amr_data_feed_readings.order(reading_date: :desc).first.reading_date)
  end

  def cached_api_information?
    information.present?
  end

  def api_latest_data_date
    return nil if information['dates'].blank?

    Date.parse(information['dates'].last)
  end

  private

  def site_id_unique_to_school
    existing = self.class.where(site_id:).where.not(id:).where.not(school:)
    errors.add(:site_id, 'is already associated with a different school') if existing.exists?
  end
end
