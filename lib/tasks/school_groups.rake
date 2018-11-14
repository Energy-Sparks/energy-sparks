namespace :school_groups do
  desc 'Create default school groups and scoreboards'
  task create_default_school_groups_and_scoreboards: :environment do
    ActiveRecord::Base.transaction do
      banes_frome_scoreboard = Scoreboard.find_or_create_by(name: 'BANES and Frome')
      sheffield_scoreboard   = Scoreboard.find_or_create_by(name: 'Sheffield')

      banes_school_group     = SchoolGroup.find_or_create_by(name: 'Bath & North East Somerset', scoreboard: banes_frome_scoreboard)

      SchoolGroup.find_or_create_by(name: 'Frome', scoreboard: banes_frome_scoreboard)
      SchoolGroup.find_or_create_by(name: 'Sheffield', scoreboard: sheffield_scoreboard)

      School.enrolled.update_all(school_group_id: banes_school_group.id)
    end
  end
end
