class SolarLoaderJobMailer < ApplicationMailer
  helper :application, :issues
  layout 'admin_mailer'

  def job_complete
    to, @solar_feed_type, @installation, @import_log = params.values_at(:to, :solar_feed_type, :installation, :import_log)
    mail(to: to, subject: subject(@solar_feed_type, @installation, :completed))
  end

  def job_failed
    to, @solar_feed_type, @installation, @error = params.values_at(:to, :solar_feed_type, :installation, :error)
    mail(to: to, subject: subject(@solar_feed_type, @installation, :failed))
  end

  private

  def subject(solar_feed_type, installation, status)
    "[energy-sparks-#{env}] #{solar_feed_type} Import for #{installation.school.name} #{status.to_s.humanize}"
  end

  def env
    ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
  end
end
