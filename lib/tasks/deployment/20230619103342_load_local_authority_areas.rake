namespace :after_party do
  desc 'Deployment task: load_local_authority_areas'
  task load_local_authority_areas: :environment do
    puts "Running deploy task 'load_local_authority_areas'"

    file_name = File.join(__dir__, 'lad-2022-05.csv')
    # LAD22CD,LAD22NM
    CSV.foreach(file_name, headers: true) do |lad|
      area = LocalAuthorityArea.find_by(code: lad[0])
      if area.present?
        warn "#{lad[0]} (#{lad[1]}) already present, skipping"
      else
        LocalAuthorityArea.create!(
          code: lad[0],
          name: lad[1]
        )
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
