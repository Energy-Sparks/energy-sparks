# frozen_string_literal: true

namespace :after_party do
  desc 'Deployment task: create_new_calendar_area_and_calendar_for_frome'
  task create_new_calendar_area_and_calendar_for_frome_and_somerset: :environment do
    puts "Running deploy task 'create_new_calendar_area_and_calendar_for_frome'"

    # Put your task implementation HERE.
    england = CalendarArea.find_by(title: 'England and Wales')
    area = CalendarArea.where(title: 'Frome', parent_area: england).first_or_create
    Loader::Calendars.load!('etc/frome-default-calendar.csv', area)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20181120103421'
  end
end
