module Onboarding
  class InsetDaysController < BaseController
    def new
      @calendar_event = @school_onboarding.school.calendar.calendar_events.new
      @calendar_event_types = CalendarEventType.inset_day
    end

    def create
      @calendar_event_types = CalendarEventType.inset_day

      @calendar_event = @school_onboarding.school.calendar.calendar_events.new(calendar_event_params)
      if @calendar_event.start_date
        @calendar_event.end_date = @calendar_event.start_date
        @calendar_event.academic_year = AcademicYear.for_date(@calendar_event.start_date)
      end
      if @calendar_event.save
        redirect_to new_onboarding_completion_path(@school_onboarding.uuid)
      else
        render :new
      end
    end

  private

    def calendar_event_params
      params.require(:calendar_event).permit(:title, :calendar_event_type_id, :start_date)
    end
  end
end
