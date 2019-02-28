class ReportsController < AdminController
  def index
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
