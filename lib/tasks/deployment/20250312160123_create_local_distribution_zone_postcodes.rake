namespace :after_party do
  desc 'Deployment task: set_school_local_distribution_zone'
  task create_local_distribution_zone_postcodes: :environment do
    puts "Running deploy task 'create_local_distribution_zone_postcodes'"

    # from https://www.xoserve.com/a-to-z/#p - https://www.xoserve.com/media/2008/postcode-exit-zone-list-may-2017.zip
    unless File.exist?('tmp/Postcode-Exit-Zone-List-May-2017.xlsx')
      s3 = Aws::S3::Client.new
      File.open('tmp/Postcode-Exit-Zone-List-May-2017.xlsx', 'wb') do |target|
        s3.get_object({ bucket: 'es-import-20250314', key: 'Postcode-Exit-Zone-List-May-2017.xlsx' }, target:)
        target.flush
        target.fsync
      end
    end
    xlsx = Roo::Excelx.new('tmp/Postcode-Exit-Zone-List-May-2017.xlsx')
    postcodes = Hash.new { |h, k| h[k] = Set.new }
    xlsx.sheets.each do |name|
      sheet = xlsx.sheet(name)
      header = sheet.row(1).each.with_index(1).to_h
      (2..sheet.last_row).each do |row|
        postcode = "#{sheet.cell(row, header['Outcode'])} #{sheet.cell(row, header['Incode'])}"
        postcodes[postcode] << sheet.cell(row, header['LDZ'])
      end
    end

    # these postcodes have multiple zones
    postcodes['SW11 3GQ'] = ['SE']
    postcodes['SE1 6HZ'] = ['SE']
    model_zones = LocalDistributionZone.pluck(:code, :id).to_h
    LocalDistributionZonePostcode.insert_all!(
      postcodes.filter_map do |postcode, zones|
        raise "#{postcode} #{zones}" if zones.length != 1
        raise "unknown zone #{zones.first}" if model_zones[zones.first].nil?
        { local_distribution_zone_id: model_zones[zones.first], postcode: }
      end)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
