namespace :after_party do
  desc 'Deployment task: Perse data config'
  task perse: :environment do
    puts "Running deploy task 'perse'"

    config = {}
    config['description'] = "Perse"
    config['identifier'] = 'perse'
    config['notes'] = "Format for data downloaded via perse"
    config['number_of_header_rows'] = 1
    config['date_format'] = "%Y-%m-%d"

    config['header_example'] = "Date,MPAN,MQ,P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P4
7,P48,P49,P50,UT1,UT2,UT3,UT4,UT5,UT6,UT7,UT8,UT9,UT10,UT11,UT12,UT13,UT14,UT15,UT16,UT17,UT18,UT19,UT20,UT21,UT22,UT23,UT24,UT25,UT26,UT27,UT28,UT29,UT30,UT31,UT32,UT33,UT34,UT35,UT36,UT37,
UT38,UT39,UT40,UT41,UT42,UT43,UT44,UT45,UT46,UT47,UT48,UT49,UT50"
    config['mpan_mprn_field'] = 'MPAN'
    config['reading_date_field'] = 'Date'
    config['reading_fields'] = "P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11,P12,P13,P14,P15,P16,P17,P18,P19,P20,P21,P22,P23,P24,P25,P26,P27,P28,P29,P30,P31,P32,P33,P34,P35,P36,P37,P38,P39,P40,P41,P42,P43,P44,P45,P46,P4
7,P48".split(",")

    AmrDataFeedConfig.create!(config)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
