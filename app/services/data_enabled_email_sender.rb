class DataEnabledEmailSender
  include OnboardingHelper

  def initialize(school)
    @school = school
  end

  def send
    unless @school.has_school_onboarding_event?(:data_enabled_email_sent)
      to = @school.activation_email_list
      if to.any?
        OnboardingMailer.with(to: to, school: @school).data_enabled_email.deliver_now
        record_event(@school.school_onboarding, :data_enabled_email_sent)
      end
    end
  end
end
