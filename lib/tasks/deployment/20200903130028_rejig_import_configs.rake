namespace :after_party do
  desc 'Deployment task: rejig_import_configs'
  task rejig_import_configs: :environment do
    puts "Running deploy task 'rejig_import_configs'"

    # Put your task implementation HERE.
    highlands = AmrDataFeedConfig.find_by(identifier: 'highlands')

    edf = highlands.attributes
    edf.delete('id')
    edf['description'] = "EDF generic feed, based highlands"
    edf['identifier'] = 'edf'

    AmrDataFeedConfig.create!(edf)

    gdst_electric = AmrDataFeedConfig.find_by(identifier: 'gdst-electricity')

    imserv_data_type_2_digit_year = gdst_electric.attributes
    imserv_data_type_2_digit_year.delete('id')
    imserv_data_type_2_digit_year['description'] = "IMServ generic feed, includes Data Type column, 2 digit year and header, flags - based gdst-electricity"
    imserv_data_type_2_digit_year['identifier'] = 'imserv-data-type-yy-flags-header'

    AmrDataFeedConfig.create!(imserv_data_type_2_digit_year)

    frome = AmrDataFeedConfig.find_by(identifier: 'frome')

    imserv_2_digit_year_no_header = frome.attributes
    imserv_2_digit_year_no_header.delete('id')
    imserv_2_digit_year_no_header['description'] = "IMServ generic feed, no Data Type column, 2 digit year and no header - based frome"
    imserv_2_digit_year_no_header['identifier'] = 'imserv-no-data-type-yy-no-header'

    AmrDataFeedConfig.create!(imserv_2_digit_year_no_header)

    frome_historical = AmrDataFeedConfig.find_by(identifier: 'frome-historical')

    imserv_4_digit_year_header = frome_historical.attributes
    imserv_4_digit_year_header.delete('id')
    imserv_4_digit_year_header['description'] = "IMServ generic feed, no Data Type column, 4 digit year and header - based frome-historical"
    imserv_4_digit_year_header['identifier'] = 'imserv-no-data-type-YYYY-header'

    AmrDataFeedConfig.create!(imserv_4_digit_year_header)

    gdst_electric_historical = AmrDataFeedConfig.find_by(identifier: 'gdst-historic-electricity')

    imserv_data_type_4_digit_year_header = gdst_electric_historical.attributes
    imserv_data_type_4_digit_year_header.delete('id')
    imserv_data_type_4_digit_year_header['description'] = "IMServ generic feed, Data Type column, 4 digit year and header, flags - based gdst-historical-electricity"
    imserv_data_type_4_digit_year_header['identifier'] = 'imserv-data-type-YYYY-flags-header'

    gdst_electric = AmrDataFeedConfig.find_by(identifier: 'gdst-electricity')

    imserv_data_type_2_digit_year_no_flags = gdst_electric.attributes
    imserv_data_type_2_digit_year_no_flags.delete('id')
    imserv_data_type_2_digit_year_no_flags['description'] = "IMServ generic feed, includes Data Type column, 2 digit year and header, no flags"
    imserv_data_type_2_digit_year_no_flags['identifier'] = 'imserv-data-type-yy-header'
    imserv_data_type_2_digit_year_no_flags['header_example'] = 'Site Id,Meter Number,Data Type,Reading Date,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30'

    AmrDataFeedConfig.create!(imserv_data_type_2_digit_year_no_flags)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end