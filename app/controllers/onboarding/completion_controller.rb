module Onboarding
  class CompletionController < BaseController
    skip_before_action :check_complete

    def new
      @school = @school_onboarding.school
      @meters = @school.meters
      @school_times = @school.school_times.sort_by {|time| SchoolTime.days[time.day]}
      if @school.calendar
        @inset_days = @school.calendar.calendar_events.inset_days.order(:start_date, :end_date)
      end
    end

    def create
      @school_onboarding.events.create(event: :onboarding_complete)
      redirect_to onboarding_completion_path(@school_onboarding.uuid)
    end

    def show
    end
  end
end
