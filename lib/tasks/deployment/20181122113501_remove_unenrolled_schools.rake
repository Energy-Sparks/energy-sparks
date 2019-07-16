# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: remove_unenrolled_schools'
  task remove_unenrolled_schools: :environment do
    puts "Running deploy task 'remove_unenrolled_schools'"

    ActiveRecord::Base.transaction do
      School.inactive.each do |school|
        puts "Removing: #{school.name}"
        school.slugs.destroy_all
        school.school_times.destroy_all
        school.destroy
      end
    end

    AfterParty::TaskRecord.create version: '20181122113501'
  end
end
