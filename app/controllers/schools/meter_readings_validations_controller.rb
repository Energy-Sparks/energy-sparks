module Schools
  class MeterReadingsValidationsController < ApplicationController
    def create
      school = School.friendly.find(params[:school_id])
      authorize! :validate_meters, school
      Amr::ValidateAndPersistReadingsService.new(school).perform
      redirect_back fallback_location: school_meters_path(school), notice: 'Meter readings validated'
    rescue => e
      Rollbar.error(e)
      redirect_back fallback_location: school_meters_path(school), alert: 'Meter reading validation FAILED!'
    end
  end
end
