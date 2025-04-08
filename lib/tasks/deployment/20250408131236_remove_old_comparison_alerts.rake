namespace :after_party do
  desc 'Deployment task: remove_old_comparison_alerts'
  task remove_old_comparison_alerts: :environment do
    puts "Running deploy task 'remove_old_comparison_alerts'"

    # Heat Saver 2024
    AlertType.where(class_name: ['AlertHeatSaver2024ElectricityComparison', 'AlertHeatSaver2024GasComparison', 'AlertHeatSaver2024StorageHeaterComparison']).destroy_all
    Comparison::Report.where(key: [:heat_saver_march_2024]).destroy_all

    # Jan August 2022/2023
    AlertType.where(class_name: ['AlertJanAug20222023ElectricityComparison', 'AlertJanAug20222023GasComparison', 'AlertJanAug20222023StorageHeaterComparison']).destroy_all
    Comparison::Report.where(key: [:jan_august_2022_2023_energy_comparison]).destroy_all

    # Layer up / Power down
    AlertType.where(class_name: ['AlertLayerUpPowerdownNovember2023ElectricityComparison', 'AlertLayerUpPowerdownNovember2023GasComparison', 'AlertLayerUpPowerdownNovember2023StorageHeaterComparison']).destroy_all
    Comparison::Report.where(key: [:layer_up_powerdown_day_november_2023]).destroy_all

    # Orphaned reports
    Comparison::Report.where(key: [:layer_up_power_down_day_november_15th_2024]).destroy_all

    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord
      .create version: AfterParty::TaskRecorder.new(__FILE__).timestamp
  end
end
