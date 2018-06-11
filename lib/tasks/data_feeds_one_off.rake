namespace :data_feeds do
  desc 'One off load'
  task one_off: [:environment] do
    wua = WeatherUndergroundArea.where(title: 'Bath').first_or_create
    pva = SolarPvTuosArea.where(title: 'Bath').first_or_create

    wu = DataFeeds::WeatherUnderground.where(title: 'Weather Underground Bath', area: wua).first_or_create
    pv = DataFeeds::SolarPvTuos.where(title: 'Solar PV Tuos Bath', area: pva).first_or_create

    pp DateTime.now
    pp "reading count: #{DataFeedReading.count}"
    pp "import temperatures"
    import_feed(wu.id, 'etc/one_off_data_load/temperatures.csv', :temperature)
    pp "reading count after : #{DataFeedReading.count}"
    pp DateTime.now
    pp "import irradiation"
    import_feed(wu.id, 'etc/one_off_data_load/solar_irradiation.csv', :solar_irradiation)
    pp "reading count after : #{DataFeedReading.count}"
    pp DateTime.now
    pp "import pv"
    import_feed(wu.id, 'etc/one_off_data_load/sheffield_solar_pv_bath.csv', :solar_pv)
    pp "reading count after : #{DataFeedReading.count}"
    pp DateTime.now
  end

  def import_feed(data_feed_id, csv_file, feed_type)

    DataFeedReading.where(feed_type: feed_type).delete_all

    items = []
    DataFeedReading.transaction do
      data_hash = CSV.foreach(csv_file, headers: true).select { |row| !row.empty? }.each do |row|
        date = Date.parse(row['at'])
        row.each do |column|
          next if column[0].nil? || column[0] == 'at'
          datestring = "#{date} #{column[0]}"
          datetime = DateTime.strptime(datestring, '%Y-%m-%d %H:%M')
          value = column[1]
          value = 0 if value == 'NaN'
          items <<  DataFeedReading.new(data_feed_id: data_feed_id, at: datetime, feed_type: feed_type, value: value)
        end #column
      end #row
    end
    pp "ready to import"
    DataFeedReading.import(items)
    pp "finished"
  end # method
end
