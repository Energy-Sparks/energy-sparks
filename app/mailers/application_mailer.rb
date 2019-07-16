# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'Energy Sparks <hello@energysparks.uk>'
  layout 'mailer'
end
