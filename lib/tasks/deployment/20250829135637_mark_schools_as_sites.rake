# rubocop:disable Metrics/BlockLength
namespace :after_party do
  desc 'Deployment task: mark_schools_as_sites'
  task mark_schools_as_sites: :environment do
    puts "Running deploy task 'mark_schools_as_sites'"

    site_urns = [
      13536,    # Swindon Academy has been split into 2 schools on ES. The bad URN is for the second school.
      10076,    # Has been split into the Senior and Junior schools?
      902431,   # School was amalgamated with another, so no current URN
      802431,   # School was amalgamated with another, so no current URN
      9145558,  # We've split the school
      934984,   # School has closed, this is the primary site of the college. We don't have the rest, or they don't exist
      944739,   # We've split the school
      935021,   # We've split the school
      923310,   # We've split the school
      935249,   # We've split the school
      937563,   # We've split the school
      9114607,  # We've split the school
      901954,   # We've split the school
      9144285,  # We've split the school
      9135968,  # We've split the school
      900648,   # We've split the school
      9137353,  # We've split the school
      936414,   # We've split the school
      946158,   # We've split the school
      9130371,  # We've split the school
      941991,   # We've split the school
      823310,   # We've split the school
      9123620,  # We've split the school
      9143545,  # We've split the school
      937842,   # We've split the school
      8135968,  # We've split the school
      116582,   # We've split the school but also reused an expired Id?
      402019,   # We've split the school but school has an incorrect id
    ]

    site_urns.each do |urn|
      School.find_by(urn: urn).update(full_school: false)
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
# rubocop:enable Metrics/BlockLength
