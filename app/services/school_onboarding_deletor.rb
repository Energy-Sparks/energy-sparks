class SchoolOnboardingDeletor
  def initialize(school_onboarding)
    @school_onboarding = school_onboarding
  end

  def delete!
    SchoolOnboarding.transaction do
      if @school_onboarding.created_user && @school_onboarding.school
        remove_school(@school_onboarding.created_user, @school_onboarding.school)
      end
      @school_onboarding.destroy
    end
  end

  private

  def remove_school(user, school)
    user.remove_school(school)
    school.consent_grants.destroy_all
    school.destroy
  end
end
