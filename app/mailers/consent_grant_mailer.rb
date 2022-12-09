class ConsentGrantMailer < ApplicationMailer
    def email_consent
      @consent_grant = params[:consent_grant]
      @title = @consent_grant.school.name
      # ensure that emails are all in English for the moment
      I18n.with_locale(:en) do
        make_bootstrap_mail(to: @consent_grant.user.email)
      end
    end
end
