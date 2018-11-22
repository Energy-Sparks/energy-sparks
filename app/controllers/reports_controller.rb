require 'dashboard'

class ReportsController < AdminController
  COLOUR_ARRAY = ['#5cb85c', "#9c3367", "#67347f", "#501e74", "#935fb8", "#e676a3", "#e4558b", "#7a9fb1", "#5297c6", "#97c086", "#3f7d69", "#6dc691", "#8e8d6b", "#e5c07c", "#e9d889", "#e59757", "#f4966c", "#e5644e", "#cd4851", "#bd4d65", "#515749", "#e5644e", "#cd4851", "#bd4d65", "#515749"].freeze

  def index
  end

  def amr_data_index
    @meters = Meter.where(active: true).includes(:school).order('schools.name')
  end

  def amr_readings_show
    @colour_hash = COLOUR_ARRAY.each_with_index.map { |colour, index| [OneDayAMRReading::AMR_TYPES.keys[index], colour] }.to_h
    @meter = Meter.includes(:amr_validated_readings).find(params[:meter_id])
    @first_reading = @meter.first_read
    respond_to do |format|
      format.json do
        @reading_summary = @meter.amr_validated_readings.order(:reading_date).pluck(:reading_date, :status).map {|day| { day[0] => day[1] }}
        @reading_summary = @reading_summary.inject(:merge!)
      end
      format.html
    end
  end

  def data_feed_show
    feed_id = params[:id]
    @feed_type = params[:feed_type].to_sym

    @data_feed = DataFeed.find(feed_id)
    @first_read = @data_feed.first_reading(@feed_type)
    @reading_summary = get_data_feed_readings(@data_feed, @feed_type)
    @missing_array = get_missing_array(@first_read, @reading_summary)
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

  def get_data_feed_readings(data_feed, feed_type)
    data_feed.data_feed_readings.where(feed_type: feed_type).order(Arel.sql('at::date')).group('at::date').count
  end

  def get_missing_array(first_reading, reading_summary)
    missing_array = (first_reading.at.to_date..Time.zone.today).collect do |day|
      if ! reading_summary.key?(day)
        [day, 'No readings']
      elsif reading_summary.key?(day) && reading_summary[day] < 48
        [day, 'Partial readings']
      elsif reading_summary.key?(day) && reading_summary[day] > 48
        [day, 'Too many readings!']
      end
    end
    missing_array.reject!(&:blank?)
  end
end
