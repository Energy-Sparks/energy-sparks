namespace :after_party do
  desc 'Deployment task: remove_ratings_from_analysis_alerts'
  task remove_ratings_from_analysis_alerts: :environment do
    puts "Running deploy task 'remove_ratings_from_analysis_alerts'"

    class_names = [
      'AdviceElectricityIntraday',
      'AdviceGasIntraday',
      'AdviceStorageHeaters',
      'AdviceSolarPV',
      'AdviceGasBoilerFrost',
      'AdviceCarbon'
    ]
    AlertType.where(class_name: class_names).update_all(has_ratings: false)

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
