# frozen_string_literal: true

# == Schema Information
#
# Table name: solar_edge_installations
#
#  id                      :bigint(8)        not null, primary key
#  access_token            :string
#  access_token_expires_at :datetime
#  active                  :boolean          default(TRUE), not null
#  api_key                 :text
#  consent_granted_at      :datetime
#  information             :json
#  mpan                    :text
#  refresh_token           :string
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

  validates :site_id, presence: true
  validate :site_id_unique_to_school

  scope :active, -> { where(active: true) }

  def display_name
    site_id
  end

  def school_number
    school.urn
  end

  def meter(meter_type = :electricity)
    meters.where(meter_type:).first
  end

  def latest_reading(meter_type = :electricity)
    meter = meter(meter_type)
    return unless meter&.amr_data_feed_readings&.any?

    meter.amr_data_feed_readings.order(parsed_date: :desc).first.parsed_date
  end

  def notify_email
    school&.default_issues_admin_user&.email || 'operations@energysparks.uk'
  end

  def can_complete_setup?
    mpan.present? && consented?
  end

  def setup_complete?
    meters.any?
  end

  def consented?
    consent_granted_at.present?
  end

  def metadata_for_meter_type(meter_type = 'FeedIn')
    return nil if information.blank? || information['inventory'].blank?

    information['inventory'].find { |item| item['meterType'] == meter_type }
  end

  def monitoring_active?
    return false if information.blank?

    information['site_details']&.dig('activationStatus') == 'ACTIVE' ||
      information.dig('site_details', 'sites', 'site', 0, 'status') == 'Active'
  end

  # We expiry tokens early to avoid clock / timing issues with generating timestamp
  def access_token_expired?
    5.seconds.from_now.utc >= access_token_expires_at
  end

  def site_api!
    refresh_api_tokens!

    DataFeeds::SolarEdge::SiteApi.new(site_id:, access_token:)
  end

  # We use UTC for expiry timestamp to avoid issues with BST/GMT changeover.
  def refresh_api_tokens!
    return if refresh_token.blank?

    with_lock do
      return false unless access_token_expired?

      begin
        tokens = DataFeeds::SolarEdge::Api.new.refresh_access_token(refresh_token)
        store_tokens(tokens)
      rescue StandardError => e
        # Ensure tokens are logged somewhere if there is an issue with the update
        # as the old refresh token is now invalid. Will need it to recover access.
        Rollbar.error(
          e,
          solar_edge_installation: id,
          tokens: tokens
        )
        raise
      end
    end
  end

  private

  def store_tokens(tokens)
    update!(
      access_token: tokens['access_token'],
      refresh_token: tokens['refresh_token'],
      access_token_expires_at: tokens['expires_in'].to_i.seconds.from_now.utc
    )
  end

  def site_id_unique_to_school
    existing = self.class.where(site_id:).where.not(id:).where.not(school:)
    errors.add(:site_id, 'is already associated with a different school') if existing.exists?
  end
end
