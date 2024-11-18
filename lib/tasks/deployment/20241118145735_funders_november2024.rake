namespace :after_party do
  desc 'Deployment task: funders_november2024'
  task funders_november2024: :environment do
    puts "Running deploy task 'funders_november2024'"

    file_name = File.join( File.expand_path(File.dirname(__FILE__)) , "funders-nov-2024.csv" )
    CSV.foreach( file_name, headers: true ) do |row|
      _school_group = row[0]
      school_name = row[1]
      funder_name = row[2]

      school = School.find_by_name(school_name)
      puts "No school called: #{school_name}" unless school
      next unless school

      if funder_name.present?
        funder = Funder.find_by_name(funder_name.rstrip)
        if funder
          school.update!(funder: funder)
        else
          puts "No funder called: #{funder_name}"
        end
      else
        #no funder in spreadsheet, as school is now archived/removed,
        #so set to nil
        school.update!(funder: nil)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
