namespace :after_party do
  desc 'Deployment task: create_bryt_data_feed_config'
  task create_bryt_data_feed_config: :environment do
    puts "Running deploy task 'create_bryt_data_feed_config'"

    config = {}
    config['description'] = "Bryt"
    config['identifier'] = 'bryt'
    config['number_of_header_rows'] = 5
    config['header_example'] = "Mpan,Settlement Date,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,Grand Total"
    config['date_format'] = "%d/%m/%Y" # e.g. 16/10/2023
    config['mpan_mprn_field'] = 'Mpan'
    config['reading_date_field'] = 'Settlement Date'
    config['reading_fields'] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]

    AmrDataFeedConfig.create!(config)


    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end