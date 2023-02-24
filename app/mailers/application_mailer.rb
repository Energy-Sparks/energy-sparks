class ApplicationMailer < ActionMailer::Base
  include DefaultUrlOptionsHelper

  default from: 'Energy Sparks <hello@energysparks.uk>'
  layout 'mailer'

  before_action :set_title

  # ensure that emails are all in English for the moment
  def make_bootstrap_mail_en(*args)
    I18n.with_locale(:en) do
      make_bootstrap_mail(*args)
    end
  end

  def set_title
    @title = params[:title] || ""
  end

  def user_emails(users)
    users.map(&:email)
  end
end
