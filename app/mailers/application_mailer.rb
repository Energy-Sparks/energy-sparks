class ApplicationMailer < ActionMailer::Base
  default from: 'Energy Sparks <hello@energysparks.uk>'
  layout 'mailer'

  before_action :set_title

  def set_title
    @title = params[:title] || ""
  end
end
