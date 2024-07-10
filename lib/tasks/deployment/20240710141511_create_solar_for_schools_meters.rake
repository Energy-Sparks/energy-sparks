namespace :after_party do
  desc 'Deployment task: create_solar_for_schools_meters'
  task create_solar_for_schools_meters: :environment do
    puts "Running deploy task 'create_solar_for_schools_meters'"

    #sfs_ids => mpxn
    METERS = {
      ['G-1197', 'E-1197', 'I-1197'] => '1600000170120'
    }
#      ['G-1199', 'E-1199', 'I-1199'] => '1640000030687',
#      ['G-1022', 'E-1022', 'I-1022'] => '2345482793413',
#      ['G-1023', 'E-1023', 'I-1023'] => '2345482793413',
#      ['G-242', 'E-242', 'I-242'] => '2700001122764',
#      ['G-258', 'E-258', 'I-258'] => '1050000907008',
#      ['G-1190', 'E-1190', 'I-1190'] => '1050000907008',
#      ['G-225', 'E-225', 'I-225'] => '1030083649169',
#      ['G-1053', 'E-1053','I-1053'] => '2380002169775',
#      ['G-1055', 'E-1055', 'I-1055'] => '1100004586710',
#      ['G-1047', 'E-1047', 'I-1047'] => '1100050937145',
#      ['G-1075', 'E-1075', 'I-1075'] => '1610002263571',
#      ['G-1076', 'E-1076', 'I-1076'] => '1610002263084',
#      ['G-685906', 'E-685906', 'I-685906'] => '2200030353610', #FIXME
#      ['G-422', 'E-422', 'I-422'] => '2200030353610', #FIXME
#      ['G-763861', 'E-763861', 'I-763861'] => '2200042780450',
#      ['G-1084', 'E-1084', 'I-1084'] => '1900005000620',
#      ['G-1093', 'E-1093', 'I-1093'] => '2376551205010',
#      ['G-221', 'E-221', 'I-221'] => '1030067967078',
#      ['G-224', 'E-224', 'I-224'] => '1030081312822',
#      ['G-1000', 'E-1000', 'I-1000'] => '2200030353596'
#    }

    def create_solar_meter(sfs_id, mpxn)
    end

    # Create one solar meter for each SfS meter serial number, using type from
    # prefix

    # Create synthetic mpan from MPAN, using the suffix

    # Set Data Source to be Solar For Schools (60)

    # Log if already exists
    # Log if MPXN not found
    # Log when created

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
