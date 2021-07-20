module Schools
  class TargetsController < ApplicationController
    load_and_authorize_resource :school

    include SchoolAggregation

    before_action :check_aggregated_school_in_cache, only: :index

    def index
      @progress = TargetsService.new(aggregate_school).progress
    end
  end
end
