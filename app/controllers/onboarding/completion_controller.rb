module Onboarding
  class CompletionController < BaseController
    include NewsletterSubscriber
    skip_before_action :check_complete, only: :show

    def new
      @school = @school_onboarding.school
      @users = @school_onboarding.school.users.reject {|u| u.id == current_user.id || u.pupil? }
      @pupil = @school_onboarding.school.users.pupil.first
      @meters = @school.meters
      @school_times = @school.school_times.sort_by {|time| SchoolTime.days[time.day]}
      if @school.calendar
        @inset_days = @school.calendar.calendar_events.inset_days.order(:start_date, :end_date)
      end
    end

    def create
      @school_onboarding.events.create(event: :onboarding_complete)

      users = @school_onboarding.school.users.reject {|u| u.id == current_user.id || u.pupil? }

      send_confirmation_instructions(users)
      create_additional_contacts(users)

      #subscribe all users to newsletters
      subscribe_newsletter(@school_onboarding.school, @school_onboarding.created_user) if @school_onboarding.subscribe_to_newsletter

      OnboardingMailer.with(school_onboarding: @school_onboarding).completion_email.deliver_now
      redirect_to onboarding_completion_path(@school_onboarding)
    end

    def show
      if @school_onboarding.school.visible?
        redirect_to school_path(@school_onboarding.school), notice: 'Your school is now active!'
      else
        :show
      end
    end

    private

    def send_confirmation_instructions(users)
      #confirm other users created during onboarding
      users.each do |user|
        user.send_confirmation_instructions unless user.confirmed?
      end
    end

    def create_additional_contacts(users)
      users.each do |user|
        @school_onboarding.events.create(event: :alert_contact_created)
        @school_onboarding.school.contacts.create!(
          user: user,
          name: user.display_name,
          email_address: user.email,
          description: 'School Energy Sparks contact'
        )
      end
    end
  end
end
