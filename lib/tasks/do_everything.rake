namespace :do do
  desc "Validate readings"
  task everything: :environment do
    puts DateTime.now.utc
  #  Rake::Task["amr_importer:validate_amr_readings"].invoke
    Rake::Task["configuration:generate_for_schools"].invoke
    Rake::Task["equivalences:create"].invoke
    Rake::Task["alerts:create"].invoke
    Rake::Task["alerts:generate_content"].invoke
  end
end
