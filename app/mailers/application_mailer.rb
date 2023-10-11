class ApplicationMailer < ActionMailer::Base
  include DefaultUrlOptionsHelper

  default from: 'Energy Sparks <hello@energysparks.uk>'
  layout 'mailer'

  before_action :set_title

  def set_title
    @title = params[:title] || ''
  end

  def user_emails(users)
    users.map(&:email)
  end
end
