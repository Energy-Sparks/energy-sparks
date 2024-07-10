module Schools
  class LiveDataController < ApplicationController
    load_resource :school

    skip_before_action :authenticate_user!
    before_action :redirect_if_disabled

    include SchoolAggregation

    before_action :check_aggregated_school_in_cache, only: :show

    def show
      @activities = ActivityType.active.live_data.sample(5)
      @actions = Recommendations::Actions.new(@school).based_on_energy_use
      @daily_variation_url = insights_school_advice_electricity_intraday_path(school)
      @timeout_interval = timeout_interval
      cache_power_consumption_service
    end

    private

    def cache_power_consumption_service
      Cads::RealtimePowerConsumptionService.cache_power_consumption_service(aggregate_school, @school.cads.last)
    end

    def timeout_interval
      ENV['LIVE_DATA_TIMEOUT'] || 60
    end

    def redirect_if_disabled
      redirect_to school_path(@school) unless EnergySparks::FeatureFlags.active?(:live_data)
    end
  end
end
