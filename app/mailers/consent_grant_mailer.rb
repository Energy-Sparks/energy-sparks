class ConsentGrantMailer < ApplicationMailer
    def email_consent
      @consent_grant = params[:consent_grant]
      make_bootstrap_mail(to: @consent_grant.user.email, subject: "Your grant of consent to Energy Sparks")
    end
end
