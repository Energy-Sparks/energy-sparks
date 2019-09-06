# frozen_string_literal: true

class CalendarsController < ApplicationController
  load_and_authorize_resource

  # GET /calendars
  # GET /calendars.json
  def index
    @top_level_calendars = Calendar.bank_holiday_calendar.order(:title)
    @child_template_calendars = Calendar.term_calendar.order(:title)
    @customised_calendars = Calendar.includes(:schools).school_calendar.order('schools.name')
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
