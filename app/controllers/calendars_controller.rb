# frozen_string_literal: true

class CalendarsController < ApplicationController
  load_and_authorize_resource

  # GET /calendars
  # GET /calendars.json
  def index
    @national_calendars = Calendar.national.includes(:schools).order(:title)
    @regional_calendars = Calendar.regional.includes(:schools).order(:title)
    @school_calendars = Calendar.school.includes(:schools).order('schools.name')
  end

  # GET /calendars/1
  # GET /calendars/1.json
  def show
  end

  # DELETE /calendars/1
  def destroy
    @calendar.update_attribute(:deleted, true)
    redirect_to calendars_url, notice: 'Calendar was marked as deleted.'
  end
end
