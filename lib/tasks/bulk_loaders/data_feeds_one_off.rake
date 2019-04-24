namespace :data_feeds do
  desc 'One off load'
  task one_off: [:environment] do
    pp DateTime.current
    %w(frome sheffield).each do |region|
      wua = WeatherUndergroundArea.find_by(title: region.capitalize)
      pva = SolarPvTuosArea.find_by(title: region.capitalize)

      wu = DataFeeds::WeatherUnderground.find_by(area: wua)
      pv = DataFeeds::SolarPvTuos.find_by(area: pva)
      pp "reading count: #{DataFeedReading.count}"
      pp "import temperatures #{region}"
      import_feed(wu.id, "etc/one_off_data_load/#{region}-temperaturedata.csv", :temperature)
      pp "reading count after : #{DataFeedReading.count}"
      pp DateTime.current
      pp "import irradiation"
      import_feed(wu.id, "etc/one_off_data_load/#{region}-solardata.csv", :solar_irradiation)
      pp "reading count after : #{DataFeedReading.count}"
      pp DateTime.current
      pp "import pv"
      import_feed(pv.id, "etc/one_off_data_load/pv-data-#{region}.csv", :solar_pv)
      pp "reading count after : #{DataFeedReading.count}"
      pp DateTime.current
    end
  end

  def import_feed(data_feed_id, csv_file_name, feed_type)
    items = []
    CSV.foreach(csv_file_name).select { |row| !row.empty? }.each do |row|
      date = DateTime.parse(row[0]).utc
      (1..48).each do |column_index|
        value = row[column_index]
        value = 0 if value == 'NaN'
        this_date_time = date + (column_index - 1) * 30.minutes
        items << DataFeedReading.new(data_feed_id: data_feed_id, at: this_date_time, feed_type: feed_type, value: value)
      end
    end
    pp "ready to import #{items.size}"
    DataFeedReading.import(items)
    pp "finished"
  end
end
