module Onboarding
  class PupilAccountController < BaseController
    before_action only: [:new, :create] do
      redirect_if_event(:pupil_account_created, new_onboarding_completion_path(@school_onboarding))
    end

    def new
      @pupil = @school_onboarding.school.users.pupil.new
    end

    def create
      @pupil = User.new_pupil(@school_onboarding.school, pupil_params)
      if @pupil.save
        @school_onboarding.events.create!(event: :pupil_account_created)
        redirect_to new_onboarding_completion_path(@school_onboarding)
      else
        render :new
      end
    end

    def edit
      @pupil = @school_onboarding.school.users.pupil.first
    end

    def update
      @pupil = @school_onboarding.school.users.pupil.first
      if @pupil.update(pupil_params)
        @school_onboarding.events.create!(event: :pupil_account_updated)
        redirect_to new_onboarding_completion_path(@school_onboarding, anchor: 'pupil-password')
      else
        render :edit
      end
    end

  private

    def pupil_params
      params.require(:user).permit(:name, :pupil_password)
    end
  end
end
