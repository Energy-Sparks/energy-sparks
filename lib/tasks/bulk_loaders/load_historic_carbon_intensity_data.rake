namespace :bulk_load do
  task historic_carbon_intensity_data: [:environment] do
    pathname = Pathname.new("tmp/uk_carbon_intensity.csv")
    raise ArgumentError, 'File is missing, should be in "tmp/uk_carbon_intensity.csv"' unless pathname.exist?
    CSV.foreach(pathname, col_sep: ',') do |row|
      date = row.shift
      DataFeeds::CarbonIntensityReading.create(reading_date: date, carbon_intensity_x48: row)
    end
  end
end
