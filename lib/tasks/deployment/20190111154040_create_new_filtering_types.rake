# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: create_new_filtering_types'
  task create_new_filtering_types: :environment do
    puts "Running deploy task 'create_new_filtering_types'"

    ActiveRecord::Base.transaction do
      impacts = [
        'Reducing gas use',
        'Reducing electricity use',
        'Reducing energy use in school hours',
        'Reducing energy use in the school holidays',
        'Reducing energy use at the weekends',
        'Reducing energy use overnight'
      ]

      subjects = %w[Science Geography Maths Citizenship]

      topics = [
        'Working scientifically',
        'Materials',
        'Light',
        'Electricity',
        'Earth and atmosphere',
        'Energy',
        'Climate change',
        'Measuring temperature',
        'Table and chart interpretation',
        'Playing an active role as citizens',
        'Bar charts',
        'Time graphs',
        'Line graphs',
        'Pie charts'
      ]

      timings = [
        'under 30 mins',
        'under 1 hour',
        'half a day',
        'long term'
      ]

      impacts.each {|name| Impact.where(name: name).first_or_create}
      subjects.each {|name| Subject.where(name: name).first_or_create}
      topics.each {|name| Topic.where(name: name).first_or_create}
      timings.each_with_index {|name, position| ActivityTiming.where(name: name, position: position).first_or_create}
    end

    AfterParty::TaskRecord.create version: '20190111154040'
  end
end
