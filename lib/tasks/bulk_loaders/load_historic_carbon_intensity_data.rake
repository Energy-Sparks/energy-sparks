namespace :bulk_load do
  task historic_carbon_intensity_data: [:environment] do
    process_carbon_feed(Date.parse('2017-09-19'), Date.yesterday)
  end
end
