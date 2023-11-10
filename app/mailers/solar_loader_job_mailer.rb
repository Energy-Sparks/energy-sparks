class SolarLoaderJobMailer < ApplicationMailer
  helper :application, :issues
  layout 'admin_mailer'

  def job_complete
    to, @title, @summary, @results_url = params.values_at(:to, :title, :summary, :results_url)
    mail(to: to, subject: "[energy-sparks-#{env}] #{@title}")
  end

  private

  def env
    ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
  end
end
