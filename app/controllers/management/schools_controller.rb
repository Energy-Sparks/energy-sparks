module Management
  class SchoolsController < ApplicationController
    load_and_authorize_resource

    include SchoolAggregation

    before_action :check_aggregated_school_in_cache

    def show
      redirect_to school_path(@school), status: :moved_permanently
    end
  end
end
