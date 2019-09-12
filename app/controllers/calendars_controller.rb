# frozen_string_literal: true

class CalendarsController < ApplicationController
  load_and_authorize_resource

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
