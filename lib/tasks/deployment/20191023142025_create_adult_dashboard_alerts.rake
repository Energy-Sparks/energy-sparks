namespace :after_party do
  desc 'Deployment task: create_adult_dashboard_alerts'
  task create_adult_dashboard_alerts: :environment do
    puts "Running deploy task 'create_adult_dashboard_alerts'"

    ActiveRecord::Base.transaction do
      AlertType.create!(
        frequency: :weekly,
        title: "Total energy use",
        description: "Total energy use",
        class_name: 'AdviceBenchmark',
        source: 'analysis',
        sub_category: :overview
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Gas: annual use",
        description: "Gas: annual use",
        class_name: 'AdviceGasAnnual',
        source: 'analysis',
        sub_category: :heating,
        fuel_type: :gas
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Electricity: annual use",
        description: "Electricity: annual use",
        class_name: 'AdviceElectricityAnnual',
        source: 'analysis',
        sub_category: :electricity_use,
        fuel_type: :electricity
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Electricity: out of hours",
        description: "Electricity: out of hours",
        class_name: 'AdviceElectricityOutHours',
        source: 'analysis',
        sub_category: :electricity_use,
        fuel_type: :electricity
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Electricity: long term",
        description: "Electricity: long term",
        class_name: 'AdviceElectricityLongTerm',
        source: 'analysis',
        sub_category: :electricity_use,
        fuel_type: :electricity
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Electricity: recent",
        description: "Electricity: recent",
        class_name: 'AdviceElectricityRecent',
        source: 'analysis',
        sub_category: :electricity_use,
        fuel_type: :electricity
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Electricity: intraday",
        description: "Electricity: intraday",
        class_name: 'AdviceElectricityIntraday',
        source: 'analysis',
        sub_category: :electricity_use,
        fuel_type: :electricity
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Gas: long term",
        description: "Gas: long term",
        class_name: 'AdviceGasLongTerm',
        source: 'analysis',
        sub_category: :heating,
        fuel_type: :gas
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Gas: recent",
        description: "Gas: recent",
        class_name: 'AdviceGasRecent',
        source: 'analysis',
        sub_category: :heating,
        fuel_type: :gas
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Gas: intraday",
        description: "Gas: intraday",
        class_name: 'AdviceGasIntraday',
        source: 'analysis',
        sub_category: :heating,
        fuel_type: :gas
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Gas: intraday",
        description: "Gas: intraday",
        class_name: 'AdviceGasIntraday',
        source: 'analysis',
        sub_category: :heating,
        fuel_type: :gas
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Boiler control: morning start",
        description: "Boiler control: morning start",
        class_name: 'AdviceGasBoilerMorningStart',
        source: 'analysis',
        sub_category: :boiler_control,
        fuel_type: :gas
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Boiler control: seasonal control",
        description: "Boiler control: seasonal control",
        class_name: 'AdviceGasBoilerSeasonalControl',
        source: 'analysis',
        sub_category: :boiler_control,
        fuel_type: :gas
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Boiler control: thermostatic",
        description: "Boiler control: thermostatic",
        class_name: 'AdviceGasBoilerThermostatic',
        source: 'analysis',
        sub_category: :boiler_control,
        fuel_type: :gas
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Boiler control: frost",
        description: "Boiler control: frost",
        class_name: 'AdviceGasBoilerFrost',
        source: 'analysis',
        sub_category: :boiler_control,
        fuel_type: :gas
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Hot water",
        description: "Hot water",
        class_name: 'AdviceGasHotWater',
        source: 'analysis',
        sub_category: :hot_water,
        fuel_type: :gas
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Storage heaters",
        description: "Storage heaters",
        class_name: 'AdviceStorageHeaters',
        source: 'analysis',
        sub_category: :storage_heaters,
        fuel_type: :electricity
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Solar PV",
        description: "Solar PV",
        class_name: 'AdviceSolarPV',
        source: 'analysis',
        sub_category: :solar_pv,
        fuel_type: :electricity
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Carbon",
        description: "Carbon",
        class_name: 'AdviceCarbon',
        source: 'analysis',
        sub_category: :co2
      )
      AlertType.create!(
        frequency: :weekly,
        title: "Energy Tariffs",
        description: "Energy Tariffs",
        class_name: 'AdviceEnergyTariffs',
        source: 'analysis',
        sub_category: :tariffs
      )
    end

    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
