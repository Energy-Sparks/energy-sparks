# frozen_string_literal: true

module Onboarding
  class ConsentController < BaseController
    skip_before_action :authenticate_user!
    before_action do
      redirect_if_event(:permission_given, new_onboarding_account_path(@school_onboarding))
    end

    def show
    end

    def create
      @school_onboarding.events.create!(event: :permission_given)
      redirect_to new_onboarding_account_path(@school_onboarding)
    end
  end
end
