namespace :schools do
  desc "Schools set countries"
  task :load_regions_and_local_authority_districts, [:csv_file] => :environment do |t,args|
    puts "#{DateTime.now.utc} Load regions and districts"

    puts "Loading from #{args.csv_file}"
    #id,RGN22NM,LAD22CD
    CSV.foreach( args.csv_file, headers: true ) do |row|
      school = School.find_by_id(row[0])
      if school.present?
        region = row[1].present? ? row[1].parameterize.underscore.to_sym : nil
        lad = LocalAuthorityArea.find_by_code(row[2])
        school.update!(region: region, local_authority_area: lad)
      else
        $stderr.puts "Can't find school with id #{row[0]}"
      end
    end

    puts "#{DateTime.now.utc} Load regions and districts end"
  end
end
