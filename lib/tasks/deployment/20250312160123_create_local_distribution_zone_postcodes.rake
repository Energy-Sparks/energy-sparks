namespace :after_party do
  desc 'Deployment task: set_school_local_distribution_zone'
  task create_local_distribution_zone_postcodes: :environment do
    puts "Running deploy task 'create_local_distribution_zone_postcodes'"

    # from rake data_feeds:ldz_postcodes
    unless File.exist?('tmp/Postcode-Exit-Zone-List-May-2017.csv')
      s3 = Aws::S3::Client.new
      File.open('tmp/Postcode-Exit-Zone-List-May-2017.csv', 'wb') do |target|
        s3.get_object({ bucket: 'es-import-20250314', key: 'Postcode-Exit-Zone-List-May-2017.csv' }, target:)
      end
    end
    model_zones = LocalDistributionZone.pluck(:code, :id).to_h
    CSV.foreach('tmp/Postcode-Exit-Zone-List-May-2017.csv', headers: true).each_slice(1000) do |slice|
      LocalDistributionZonePostcode.upsert_all(
        slice.map { |row| { local_distribution_zone_id: model_zones[row['Zone']], postcode: row['Postcode'] } }.uniq,
        unique_by: :postcode)
    end

    # these postcodes have multiple zones
    LocalDistributionZonePostcode.upsert_all([{ local_distribution_zone_id: model_zones['SE'], postcode: 'SE1 6HZ' },
                                              { local_distribution_zone_id: model_zones['SE'], postcode: 'SW11 3GQ' }],
                                              unique_by: :postcode)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
