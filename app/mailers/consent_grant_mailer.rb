class ConsentGrantMailer < ApplicationMailer
    def email_consent
      @consent_grant = params[:consent_grant]
      @title = @consent_grant.school.name
      make_bootstrap_mail(to: @consent_grant.user.email)
    end
end
