# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: add_default_school_groups_and_scoreboards'
  task add_default_school_groups_and_scoreboards: :environment do
    puts "Running deploy task 'add_default_school_groups_and_scoreboards'"

    ActiveRecord::Base.transaction do
      banes_frome_scoreboard = Scoreboard.find_or_create_by(name: 'Bath & North East Somerset and Frome')
      sheffield_scoreboard   = Scoreboard.find_or_create_by(name: 'Sheffield')

      banes_school_group     = SchoolGroup.find_or_create_by(name: 'Bath & North East Somerset', scoreboard: banes_frome_scoreboard)

      SchoolGroup.find_or_create_by(name: 'Frome', scoreboard: banes_frome_scoreboard)
      SchoolGroup.find_or_create_by(name: 'Sheffield', scoreboard: sheffield_scoreboard)

      School.active.where(school_group_id: nil).update_all(school_group_id: banes_school_group.id)

      AfterParty::TaskRecord.create version: '20181115092511'
    end
  end
end
