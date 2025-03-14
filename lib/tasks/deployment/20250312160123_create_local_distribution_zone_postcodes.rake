namespace :after_party do
  desc 'Deployment task: set_school_local_distribution_zone'
  task create_local_distribution_zone_postcodes: :environment do
    puts "Running deploy task 'create_local_distribution_zone_postcodes'"

    postcodes = if File.exist?('postcode_to_ldz.json')
                  File.read('postcode_to_ldz.json')
                else
                  s3 = Aws::S3::Client.new
                  s3.get_object(bucket: 'es-import-20250314', key: 'postcode_to_ldz.json').body.read
                end
    postcodes = JSON.parse(postcodes)
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
