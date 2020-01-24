# frozen_string_literal: true

class CalendarsController < ApplicationController
  load_and_authorize_resource

  # GET /calendars/1
  def show
    if @calendar.schools.count == 1
      @school = @calendar.schools.first
    end
  end
end
