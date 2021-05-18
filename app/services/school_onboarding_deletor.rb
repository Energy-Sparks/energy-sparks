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
    user.remove_cluster_school(school)
    if user.school == school
      if user.cluster_schools_for_switching.any?
        user.update!(school: user.cluster_schools_for_switching.first)
      else
        user.update!(school: nil, role: :school_onboarding)
      end
    end
    school.consent_grants.destroy_all
    school.delete
  end
end
