class ConsentGrantMailer < ApplicationMailer
    def email_consent
      @consent_grant = params[:consent_grant]
      make_bootstrap_mail(to: @consent_grant.user.email, subject: t(:subject, scope: [:consent_grant_mailer]))
    end
end
