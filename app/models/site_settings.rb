# == Schema Information
#
# Table name: site_settings
#
#  audit_activities_bonus_points         :integer          default(0)
#  created_at                            :datetime         not null
#  default_import_warning_days           :integer          default(10)
#  id                                    :bigint(8)        not null, primary key
#  management_priorities_dashboard_limit :integer          default(5)
#  management_priorities_page_limit      :integer          default(10)
#  message_for_no_contacts               :boolean          default(TRUE)
#  message_for_no_pupil_accounts         :boolean          default(TRUE)
#  photo_bonus_points                    :integer          default(0)
#  prices                                :jsonb
#  temperature_recording_months          :jsonb
#  updated_at                            :datetime         not null
#

class SiteSettings < ApplicationRecord
  include EnergyTariffHolder
  store_accessor :prices, :electricity_price, :solar_export_price, :gas_price
  validates :electricity_price, :solar_export_price, :gas_price, numericality: { only_float: true, allow_blank: false }
  validates :photo_bonus_points, numericality: { greater_than_or_equal_to: 0 }
  validates :audit_activities_bonus_points, numericality: { greater_than_or_equal_to: 0 }

  after_save :delete_current_prices_cache

  CURRENT_PRICES_CACHE_KEY = 'site_settings_current_prices'.freeze

  def self.current
    order('created_at DESC').first || new
  end

  def temperature_recording_month_numbers
    temperature_recording_months.reject(&:blank?).map(&:to_i)
  end

  def self.current_prices
    Rails.cache.fetch(CURRENT_PRICES_CACHE_KEY) do
      OpenStruct.new(current.prices)
    end
  end

  private

  def delete_current_prices_cache
    Rails.cache.delete(CURRENT_PRICES_CACHE_KEY)
  end
end
