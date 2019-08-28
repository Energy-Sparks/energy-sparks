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

  # GET /calendars/new
  def new
    build_terms
  end

  # GET /calendars/1/edit
  def edit
    build_terms
    redirect_to calendar_path(@calendar) if @calendar.template?x
  end

  # POST /calendars
  def create
    if @calendar.save
      redirect_to @calendar, notice: 'Calendar was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /calendars/1
  def update
    if @calendar.update(calendar_params)
      redirect_to @calendar, notice: 'Calendar was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /calendars/1
  def destroy
    @calendar.update_attribute(:deleted, true)
    redirect_to calendars_url, notice: 'Calendar was marked as deleted.'
  end

  private

  def calendar_params
    params.require(:calendar).permit(:name)
  end

  def build_terms
    number_to_build = 6 - @calendar.terms.count
    number_to_build = 1 if number_to_build < 1
    number_to_build.times do
      @calendar.terms.build
    end
  end
end
