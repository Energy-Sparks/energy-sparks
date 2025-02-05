namespace :schools do
  desc 'Run report to check data availability for targets feature'
  task fuel_data_analysis_report: [:environment] do
    puts "#{Time.zone.now} Generating fuel data analysis report"
    filename = "/tmp/school-fuel-data-analysis.csv"
    CSV.open(filename, "w") do |csv|
     csv << ["ID","School","School Group","School Type","Country","Funder","Activation Date","Electricity?",
       "Electricity Start","Electricity End","Gas?", "Gas Start","Gas End",
       "Storage heaters?","Storage heater Start","Storage heater End",
       "Solar?","Swimming Pool","Biomass?","District heating?","LPG?","Oil?"]
     School.process_data.order(:name).each do |s|
      csv << [
        s.id,
        s.name,
        s.area_name,
        s.school_type,
        s.country,
        s.funder&.name,
        (s.activation_date || s.created_at.to_date).iso8601,
        s.has_electricity?,
        s.configuration.aggregate_meter_dates.dig("electricity", "start_date"),
        s.configuration.aggregate_meter_dates.dig("electricity", "end_date"),
        s.has_gas?,
        s.configuration.aggregate_meter_dates.dig("gas", "start_date"),
        s.configuration.aggregate_meter_dates.dig("gas", "end_date"),
        s.has_storage_heaters?,
        s.configuration.aggregate_meter_dates.dig("storage_heater", "start_date"),
        s.configuration.aggregate_meter_dates.dig("storage_heater", "end_date"),
        s.has_solar_pv?,
        s.has_swimming_pool,
        s.heating_biomass,
        s.heating_district_heating,
        s.heating_lpg,
        s.heating_oil
      ]
     end
    end
    puts "#{Time.zone.now} Data written to #{filename}"
    puts "#{Time.zone.now} Generating fuel data analysis report"
  end
end
