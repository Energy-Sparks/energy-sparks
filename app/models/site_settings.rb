# == Schema Information
#
# Table name: site_settings
#
#  created_at                            :datetime         not null
#  id                                    :bigint(8)        not null, primary key
#  management_priorities_dashboard_limit :integer          default(5)
#  management_priorities_page_limit      :integer          default(10)
#  message_for_no_contacts               :boolean          default(TRUE)
#  message_for_no_pupil_accounts         :boolean          default(TRUE)
#  temperature_recording_months          :jsonb
#  updated_at                            :datetime         not null
#

class SiteSettings < ApplicationRecord
  store_accessor :prices, :electricity_price, :solar_export_price, :gas_price, :oil_price
  validates :electricity_price, :solar_export_price, :gas_price, :oil_price, presence: true, numericality: { only_float: true, allow_blank: true }
  after_create :invalidate_current_prices_cache

  SITE_SETTINGS_CURRENT_PRICE_CACHE_KEY = 'site_settings_current_prices'.freeze

  def self.current
    order('created_at DESC').first || new
  end

  def temperature_recording_month_numbers
    temperature_recording_months.reject(&:blank?).map(&:to_i)
  end

  def self.current_prices
    Rails.cache.fetch(SITE_SETTINGS_CURRENT_PRICE_CACHE_KEY) do
      OpenStruct.new(current.prices)
    end
  end

  private

  def invalidate_current_prices_cache
    Rails.cache.delete(SITE_SETTINGS_CURRENT_PRICE_CACHE_KEY)
  end
end
