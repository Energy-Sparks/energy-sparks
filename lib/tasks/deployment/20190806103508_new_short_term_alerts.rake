namespace :after_party do
  desc 'Deployment task: new_short_term_alerts'
  task new_short_term_alerts: :environment do
    puts "Running deploy task 'new_short_term_alerts'"

    ActiveRecord::Base.transaction do
      AlertType.where(
        source: :analytics,
        fuel_type: :electricity,
        frequency: :weekly,
        class_name: 'AlertSchoolWeekComparisonElectricity',
        title: 'Comparison of last 2 school weeks electricity',
        description: 'Compares the electricity usage between over the last 2 school weeks.'
      ).first_or_create!
      AlertType.where(
        source: :analytics,
        fuel_type: :electricity,
        frequency: :weekly,
        class_name: 'AlertPreviousHolidayComparisonElectricity',
        title: 'Electricity Comparison with previous holiday',
        description: 'Compares electricity consumption of the most recent holiday with the previous one. Normalises the estimated kWh for the previous holiday to the same number of weekdays and weekend days as the current holiday. So if you are comparing a recent two week holiday with a previous 1 week holiday, the kWh value for the previous holiday will be roughly doubled to take this into account.'
      ).first_or_create!
      AlertType.where(
        source: :analytics,
        fuel_type: :electricity,
        frequency: :weekly,
        class_name: 'AlertPreviousYearHolidayComparisonElectricity',
        title: 'Compares electricity usage with previous year',
        description: 'Compares current holiday usage with corresponding holiday on the previous year. Normalising the holiday, a year ago for the same number of days in the current holiday.'
      ).first_or_create!
      AlertType.where(
        source: :analytics,
        fuel_type: :gas,
        frequency: :weekly,
        class_name: 'AlertSchoolWeekComparisonGas',
        title: 'Comparison of last 2 school weeks gas alert',
        description: 'Compares the gas usage between over the last 2 school weeks. Comparison is temperature compensated (previous week only), between corresponding days of week, so the current weeks Monday temperature, is used to compensate/adjust the previous weeks Monday temperature.'
      ).first_or_create!
      AlertType.where(
        source: :analytics,
        fuel_type: :gas,
        frequency: :weekly,
        class_name: 'AlertPreviousHolidayComparisonGas',
        title: 'Comparison with previous holidays gas usage',
        description: 'Compares with the previous holiday’s gas consumption. Normalised to the number of weekdays and weekend days in the current holiday period. Temperature compensation adjusts the previous weeks daily kWh and temperature values to the average of the current holiday.'
      ).first_or_create!
      AlertType.where(
        source: :analytics,
        fuel_type: :gas,
        frequency: :weekly,
        class_name: 'AlertPreviousYearHolidayComparisonGas',
        title: 'Compare gas usage with same holiday previous year',
        description: 'Compares with the corresponding holiday the previous year’s gas consumption. Normalised to the number of weekdays and weekend days in the current holiday period. Temperature compensation adjusts the previous weeks daily kWh and temperature values to the average of the current holiday.'
      ).first_or_create!
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
