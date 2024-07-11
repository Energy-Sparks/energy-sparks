namespace :after_party do
  desc 'Deployment task: create_solar_for_schools_meters'
  task create_solar_for_schools_meters: :environment do
    puts "Running deploy task 'create_solar_for_schools_meters'"

    #List of Solar for Schools serial numbers => existing meter in our system
    #Config matches spreadsheet provided internally to make changes easier
    METERS = {
      ['G-1197', 'E-1197', 'I-1197'] => '1600000170120',
      ['G-1199', 'E-1199', 'I-1199'] => '1640000030687',
      ['G-1022', 'E-1022', 'I-1022'] => '2345482793413',
      ['G-1023', 'E-1023', 'I-1023'] => '2345482793413',
      ['G-242', 'E-242', 'I-242'] => '2700001122764',
      ['G-258', 'E-258', 'I-258'] => '1050000907008',
      ['G-1190', 'E-1190', 'I-1190'] => '1050000907008',
      ['G-225', 'E-225', 'I-225'] => '1030083649169',
      ['G-1053', 'E-1053','I-1053'] => '2380002169775',
      ['G-1055', 'E-1055', 'I-1055'] => '1100004586710',
      ['G-1047', 'E-1047', 'I-1047'] => '1100050937145',
      ['G-1075', 'E-1075', 'I-1075'] => '1610002263571',
      ['G-1076', 'E-1076', 'I-1076'] => '1610002263084',
      ['G-685906', 'E-422', 'I-422'] => '2200030353610', #confirmed that this is different to others
      ['G-763861', 'E-763861', 'I-763861'] => '2200042780450',
      ['G-1084', 'E-1084', 'I-1084'] => '1900005000620',
      ['G-1093', 'E-1093', 'I-1093'] => '2376551205010',
      ['G-221', 'E-221', 'I-221'] => '1030067967078',
      ['G-224', 'E-224', 'I-224'] => '1030081312822',
      ['G-1000', 'E-1000', 'I-1000'] => '2200030353596'
    }

    # Determine meter type from prefix
    # G = Generation, E = Export, I = Import (electricity)
    def meter_type(sfs_id)
      case sfs_id
      when /^G\-/
        :solar_pv
      when /^E\-/
        :exported_solar_pv
      else
        :electricity
      end
    end

    # Determine type for meter and attach it to the same school as the
    # existing meter
    def create_solar_meter(sfs_id, existing_meter)
      meter_type = meter_type(sfs_id)
      if meter_type.nil?
        puts "Unable to determine meter_type for #{sfs_id}, skipping"
        return
      end

      # Create synthetic mpan from MPAN, using the suffix from serial number
      suffix = sfs_id.split("-").last
      synthetic_mpan_mprn = Dashboard::Meter.synthetic_combined_meter_mpan_mprn_from_urn(suffix, meter_type)

      # Create one solar meter for each SfS meter serial number, unless already exists
      if Meter.find_by_mpan_mprn(synthetic_mpan_mprn).present?
        puts "Meter #{synthetic_mpan_mprn} already exists, skipping"
      else
        meter = Meter.create!(
          mpan_mprn: synthetic_mpan_mprn.to_i,
          meter_serial_number: sfs_id,
          meter_type: meter_type,
          pseudo: true,
          name: sfs_id,
          school: existing_meter.school,
          data_source_id: 60, #Solar for Schools
          active: false # Default to inactive to allow admins to update
        )
        puts "Created meter #{synthetic_mpan_mprn}, #{meter.id}"
      end
    end

    METERS.each do |sfs_ids, mpxn|
      existing_meter = Meter.find_by_mpan_mprn(mpxn)
      puts "Unable to find existing electricity meter #{mpxn}, skipping" unless existing_meter
      next unless existing_meter

      sfs_ids.each do |sfs_id|
        create_solar_meter(sfs_id, existing_meter)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
