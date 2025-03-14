namespace :after_party do
  desc 'Deployment task: set_school_local_distribution_zone'
  task set_school_local_distribution_zone: :environment do
    puts "Running deploy task 'set_school_local_distribution_zone'"

    def search_for_zone(term)
      LocalDistributionZonePostcode.where('postcode LIKE ?', term)
                                   .pluck(:local_distribution_zone_id)
                                   .tally.max_by { |_, count| count }&.first
    end

    School.active.each do |school|
      postcode = school.postcode.upcase.delete(' ')
      outcode = postcode[0..-4]
      incode = postcode[-3..]
      zone_id = LocalDistributionZonePostcode.find_by(postcode: "#{outcode} #{incode}")&.local_distribution_zone_id
      if zone_id.nil?
        zone_id = search_for_zone("#{outcode} %")
        if zone_id.nil?
          zone_id = search_for_zone("#{outcode.sub(/\d+$/, '')}%")
        end
      end
      school.update!(local_distribution_zone_id: zone_id)
    end

    # Put your task implementation HERE.
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
