class ApplicationMailer < ActionMailer::Base
  include DefaultUrlOptionsHelper
  include PremailerOverrideHelper

  default from: 'Energy Sparks <hello@energysparks.uk>'
  layout 'mailer'

  before_action :set_title

  def set_title
    @title = params[:title] || ''
  end

  def user_emails(users)
    users.map(&:email)
  end

  def env
    ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
  end

  def prevent_delivery_from_test
    mail.perform_deliveries = false unless ENV['SEND_AUTOMATED_EMAILS'] == 'true'
  end
end
