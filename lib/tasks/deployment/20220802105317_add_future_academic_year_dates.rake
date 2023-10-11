namespace :after_party do
  desc 'Deployment task: add_scottish_future_academic_year_dates'
  task add_future_academic_year_dates: :environment do
    puts "Running deploy task 'add_scottish_future_academic_year_dates'"

    national = Calendar.national.where(title: 'Scotland').first
    latest_year = national.academic_years.maximum(:end_date).year
    # scottish years run from 1st August to 31st July in our db
    # so specify different dates
    factory = AcademicYearFactory.new(national, start_date: '01-08', end_date: '31-07')
    factory.create(start_year: latest_year, end_year: latest_year + 5)

    national = Calendar.national.where(title: 'England and Wales').first
    latest_year = national.academic_years.maximum(:end_date).year
    # use default start/end from factory ('01-09', '31-08')
    factory = AcademicYearFactory.new(national)
    factory.create(start_year: latest_year, end_year: latest_year + 5)

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
