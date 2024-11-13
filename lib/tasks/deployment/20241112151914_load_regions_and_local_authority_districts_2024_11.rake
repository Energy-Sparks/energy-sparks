namespace :after_party do
  desc 'Deployment task: load_regions_and_local_authority_districts_2024_11'
  task load_regions_and_local_authority_districts_2024_11: :environment do
    puts "Running deploy task 'load_regions_and_local_authority_districts_2024_11'"

    file_name = File.join( File.expand_path(File.dirname(__FILE__)) , "schools-to-lads-2024-11.csv" )
    #id,RGN22NM,LAD22CD
    CSV.foreach( file_name, headers: true ) do |row|
      school = School.find_by_id(row[0])
      if school.present?
        region = row[1].present? ? row[1].parameterize.underscore.to_sym : nil
        lad = LocalAuthorityArea.find_by_code(row[2])
        school.update!(region: region, local_authority_area: lad)
      else
        $stderr.puts "Can't find school with id #{row[0]}"
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
