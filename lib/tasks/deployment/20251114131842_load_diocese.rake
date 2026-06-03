namespace :after_party do
  desc 'Deployment task: load_diocese'
  task load_diocese: :environment do
    puts "Running deploy task 'load_diocese'"

    file_name = File.join(__dir__, 'diocese.csv')
    CSV.foreach(file_name, headers: true) do |row|
      name = row['Diocese']
      dfe_code = row['Code']

      SchoolGroup.find_or_create_by(dfe_code:) do |school_group|
        school_group.name = name
        school_group.group_type = :diocese
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
