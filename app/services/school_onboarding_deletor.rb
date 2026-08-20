class SchoolOnboardingDeletor
  def initialize(school_onboarding)
    @school_onboarding = school_onboarding
  end

  def delete!
    raise 'Can only remove incomplete onboardings' unless @school_onboarding.incomplete?

    SchoolOnboarding.transaction do
      if @school_onboarding.created_user && @school_onboarding.school
        @school_onboarding.created_user.remove_school(@school_onboarding.school)
      end

      if @school_onboarding.school
        @school_onboarding.school.update!(visible: false, active: false)
        @school_onboarding.school.destroy
      else
        @school_onboarding.destroy
      end
    end
  end
end
