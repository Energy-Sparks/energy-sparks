module Onboarding
  class InsetDaysController < BaseController
    before_action :load_event_types

    def new
      @calendar_event = @school_onboarding.school.calendar.calendar_events.new
    end

    def create
      @calendar_event = @school_onboarding.school.calendar.calendar_events.new(calendar_event_params)
      complete_event_details(@calendar_event)
      if @calendar_event.save
        redirect_to new_onboarding_completion_path(@school_onboarding, anchor: 'inset-days')
      else
        render :new
      end
    end

    def edit
      @calendar_event = @school_onboarding.school.calendar.calendar_events.find(params[:id])
    end

    def update
      @calendar_event = @school_onboarding.school.calendar.calendar_events.find(params[:id])
      @calendar_event.attributes = calendar_event_params
      complete_event_details(@calendar_event)
      if @calendar_event.save
        redirect_to new_onboarding_completion_path(@school_onboarding, anchor: 'inset-days')
      else
        render :edit
      end
    end

    def destroy
      calendar_event = @school_onboarding.school.calendar.calendar_events.find(params[:id])
      calendar_event.destroy
      redirect_to new_onboarding_completion_path(@school_onboarding, anchor: 'inset-days')
    end

    private

    def load_event_types
      @calendar_event_types = CalendarEventType.inset_day
    end

    def complete_event_details(event)
      event.end_date = event.start_date if event.start_date
    end

    def calendar_event_params
      params.require(:calendar_event).permit(:calendar_event_type_id, :start_date)
    end
  end
end
