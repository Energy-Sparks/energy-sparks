class ConsentRequestMailer < ApplicationMailer
  def request_consent
    @school = params[:school]
    # ensure that emails are all in English for the moment
    I18n.with_locale(:en) do
      make_bootstrap_mail(to: params[:emails])
    end
  end
end
