namespace :after_party do
  desc 'Deployment task: turn_on_first_batch_of_variable_alerts'
  task turn_on_first_batch_of_variable_alerts: :environment do
    puts "Running deploy task 'turn_on_first_batch_of_variable_alerts'"

    ActiveRecord::Base.transaction do
      %w(
        AlertChangeInDailyElectricityShortTerm AlertChangeInDailyGasShortTerm AlertChangeInElectricityBaseloadShortTerm
        AlertOutOfHoursElectricityUsage AlertOutOfHoursGasUsage
      ).each do |class_name|
        puts "Enabling variables for #{class_name}"
        AlertType.find_by!(class_name: class_name).update!(has_variables: true)
      end
    end

    AfterParty::TaskRecord.create version: '20190322092957'
  end
end
