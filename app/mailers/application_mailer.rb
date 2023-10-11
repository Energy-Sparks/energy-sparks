class ApplicationMailer < ActionMailer::Base
  include DefaultUrlOptionsHelper

  default from: 'Energy Sparks <hello@energysparks.uk>'
  layout 'mailer'

  before_action :set_title

  def set_title
    @title = params[:title] || ""
  end

  def user_emails(users)
    users.map(&:email)
  end

  #We use bootstrap-email to process all outgoing email to users. But, due to
  #a performance issue, we don't use it for some admin mailers.
  #
  #For the admin mailers we rely on premailer and the premailer-rails gem.
  #By default premailer-rails will process all email using premailer.
  #
  #But we dont want that behaviour for emails that will be processed using
  #bootstrap-email. So we have to explicitly disable the premailer integration
  #here when calling make_bootstrap_mail.
  #
  #The bootstrap-email code still ends up calling premailer, but in a different
  #way after doing some pre- and post- processing of the generated email.
  #
  #Overidding the method here avoids having to add this argument to all non-admin
  #mailers. It also ensures that our localised emails work correctly.
  def make_bootstrap_mail(**kwargs)
    super(kwargs.merge({ skip_premailer: true }))
  end
end
