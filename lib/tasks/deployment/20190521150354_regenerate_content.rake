# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: regenerate_content'
  task regenerate_content: :environment do
    puts "Running deploy task 'regenerate_content'"

    School.all.each do |school|
      Alerts::GenerateContent.new(school).perform
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
