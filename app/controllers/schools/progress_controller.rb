require 'benchmark'

module Schools
  # Redirect old urls
  class ProgressController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!

    def index
      redirect_to electricity_school_progress_index_path
    end

    def electricity
      @school_target = @school.most_recent_target
      redirect_to electricity_school_school_target_progress_index_path(@school, @school_target)
    end

    def gas
      @school_target = @school.most_recent_target
      redirect_to gas_school_school_target_progress_index_path(@school, @school_target)
    end

    def storage_heater
      @school_target = @school.most_recent_target
      redirect_to storage_heater_school_school_target_progress_index_path(@school, @school_target)
    end
  end
end
