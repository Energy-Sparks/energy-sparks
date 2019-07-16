# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: update_topics_list'
  task update_topics_list: :environment do
    puts "Running deploy task 'update_topics_list'"

    new_topic_list = [
      'Articulate and justify arguments and opinions',
      'Charts, graphs and tables',
      'Climate change',
      'Earth and atmosphere',
      'Electricity',
      'Energy',
      'Light',
      'Materials',
      'Measuring temperature',
      'Playing an active role as citizens',
      'Working scientifically'
    ]

    new_topic_list.each do |topic|
      Topic.where(name: topic).first_or_create!
    end

    Topic.where.not(name: new_topic_list).destroy_all

    AfterParty::TaskRecord.create version: '20190125103606'
  end
end
