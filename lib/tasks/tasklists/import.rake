namespace :tasklists do
  desc 'Import audit actions and activities and programme activities'
  task import: [:environment] do
    puts "#{Time.zone.now} tasklists import start"

    # Empty out existing tasks



    Audit.all.each do |audit|
    end

    ProgrammeType.all.each do |programme_type|
    end

    Programme.all.each do |programme|
    end

    puts "#{Time.zone.now} tasklists import end"
  end
end

