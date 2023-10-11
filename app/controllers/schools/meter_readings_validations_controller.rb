module Schools
  class MeterReadingsValidationsController < ApplicationController
    def create
      @school = School.friendly.find(params[:school_id])
      authorize! :validate_meters, @school
      Amr::ValidateAndPersistReadingsService.new(@school).perform
      redirect_back fallback_location: school_meters_path(@school), notice: 'Meter readings validated'
    rescue StandardError => e
      Rollbar.error(e)
      @error = e
      render :error
    end
  end
end
