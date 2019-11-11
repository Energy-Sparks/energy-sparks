module Schools
  class AggregatedMeterCollectionsController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!

    def post
      # JSON request to load cache
      service = AggregateSchoolService.new(@school)
      service.aggregate_school unless service.in_cache?

      respond_to do |format|
        format.json { render json: { status: 'aggregated' }}
      end
    rescue => e
      Rollbar.error(e)
      respond_to do |format|
        format.json { render json: { status: 'error', message: e.message }, status: :internal_server_error}
      end
    end
  end
end
