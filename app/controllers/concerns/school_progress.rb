module SchoolProgress
  extend ActiveSupport::Concern

private

  def prompt_for_target?
    EnergySparks::FeatureFlags.active?(:school_targets) && !@school.has_target? && Targets::SchoolTargetService.new(@school).enough_data?
  end

  def calculate_current_progress
    @electricity_progress = {
      usage: progress_service.current_monthly_usage(:electricity),
      target: progress_service.current_monthly_target(:electricity),
      progress: progress_service.cumulative_progress(:electricity)
    }
    @gas_progress = {
      usage: progress_service.current_monthly_usage(:gas),
      target: progress_service.current_monthly_target(:gas),
      progress: progress_service.cumulative_progress(:gas)
    }
    @storage_heater_progress = {
      usage: progress_service.current_monthly_usage(:storage_heaters),
      target: progress_service.current_monthly_target(:storage_heaters),
      progress: progress_service.cumulative_progress(:storage_heaters)
    }
  end

  def setup_management_table
    @overview_table = progress_service.setup_management_table
  end

  def progress_service
    @progress_service ||= Targets::ProgressService.new(@school, aggregate_school)
  end
end
