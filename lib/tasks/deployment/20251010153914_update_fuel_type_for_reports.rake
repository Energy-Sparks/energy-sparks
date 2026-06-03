namespace :after_party do
  desc 'Deployment task: update_fuel_type_for_reports'
  task update_fuel_type_for_reports: :environment do
    puts "Running deploy task 'update_fuel_type_for_reports'"

    Comparison::ReportGroup.all.find_each do |report_group|
      case report_group.title
      when 'Electricity Benchmarks'
        report_group.reports.update_all(fuel_type: :electricity)
      when 'Gas and Storage Heater Benchmarks'
        report_group.reports.update_all(fuel_type: :gas) # gas by default
        report_group.reports.where("key ~ 'storage'").update_all(fuel_type: :storage_heater)
      when 'Solar Benchmarks'
        report_group.reports.update_all(fuel_type: :solar_pv)
      else
        report_group.reports.update_all(fuel_type: :multiple)
      end
    end

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
