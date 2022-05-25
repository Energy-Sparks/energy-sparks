class ApplicationMailer < ActionMailer::Base
  default from: 'Energy Sparks <hello@energysparks.uk>'
  layout 'mailer'

  before_action :set_title

  def default_url_options
    if Rails.env.production?
      { host: I18n.locale == :cy ? ENV['WELSH_APPLICATION_HOST'] : ENV['APPLICATION_HOST'] }
    else
      super
    end
  end

  def set_title
    @title = params[:title] || ""
  end
end
