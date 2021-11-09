module Onboarding
  class OnboardingDataEnabledListener
    # TDOO
    # this message not used yet - will be broadcast when a school has data enabled..
    # may need to review the source of the broadcast (might not be SchoolCreator)
    def school_data_enabled(school)
      ActivationEmailSender.new(school).send
    end
  end
end
