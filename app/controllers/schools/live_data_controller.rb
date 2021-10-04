module Schools
  class LiveDataController < ApplicationController
    load_resource :school

    before_action :redirect_if_disabled

    def show
    end

    private

    def redirect_if_disabled
      redirect_to school_path(@school) unless EnergySparks::FeatureFlags.active?(:live_data)
    end
  end
end
