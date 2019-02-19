require 'dashboard'

class ReportsController < AdminController
  COLOUR_ARRAY = ['#5cb85c', "#9c3367", "#67347f", "#501e74", "#935fb8", "#e676a3", "#e4558b", "#7a9fb1", "#5297c6", "#97c086", "#3f7d69", "#6dc691", "#8e8d6b", "#e5c07c", "#e9d889", "#e59757", "#f4966c", "#e5644e", "#cd4851", "#bd4d65", "#515749", "#e5644e", "#cd4851", "#bd4d65", "#515749"].freeze

  def index
  end

  def loading
    @schools = School.active.order(:name)
  end

  def cache_report
    @cache_keys = Rails.cache.instance_variable_get(:@data).keys
    @cache_report = @cache_keys.map do |key|
      created_at = Rails.cache.send(:read_entry, key, {}).instance_variable_get('@created_at')
      expires_in = Rails.cache.send(:read_entry, key, {}).instance_variable_get('@expires_in')
      expiry_time = created_at + expires_in
      minutes_left = ((Time.at(expiry_time).utc - Time.now.utc) / 1.minute).round
      { key: key, created_at: Time.at(created_at).utc, expiry_time: Time.at(expiry_time).utc, minutes_left: minutes_left }
    end
  end
end
