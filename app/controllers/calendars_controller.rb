# frozen_string_literal: true

class CalendarsController < ApplicationController
  load_and_authorize_resource

  # GET /calendars
  # GET /calendars.json
  def index
    @top_level_calendars = Calendar.template.includes(:schools).where(based_on_id: nil).order(:title)
    @child_template_calendars = Calendar.template.includes(:schools).where.not(based_on_id: nil).order(:title)
    @customised_calendars = Calendar.custom.includes(:schools).order('schools.name')
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
