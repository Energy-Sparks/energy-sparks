module Onboarding
  class CompletionController < BaseController
    skip_before_action :check_complete, only: :show

    def new
      @school = @school_onboarding.school
      @pupil = @school_onboarding.school.users.pupil.first
      @meters = @school.meters
      @school_times = @school.school_times.sort_by {|time| SchoolTime.days[time.day]}
      if @school.calendar
        @inset_days = @school.calendar.calendar_events.inset_days.order(:start_date, :end_date)
      end
    end

    def create
      @school_onboarding.events.create(event: :onboarding_complete)
      OnboardingMailer.with(school_onboarding: @school_onboarding).completion_email.deliver_now
      redirect_to onboarding_completion_path(@school_onboarding)
    end

    def show
      if @school_onboarding.school.active?
        redirect_to school_path(@school_onboarding.school), notice: 'Your school is now active!'
      else
        render :show
      end
    end
  end
end
