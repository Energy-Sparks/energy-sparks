class SolarLoaderJobMailer < ApplicationMailer
  helper :application, :issues
  layout 'admin_mailer'

  def job_complete
    to, @solar_feed_type, @installation, @import_log, @error =
      params.values_at(:to, :solar_feed_type, :installation, :import_log, :error)
    @import_subject = @installation.respond_to?(:school) ? @installation.school.name : @installation.display_name
    mail(to:, subject:)
  end

  private

  def subject
    "[energy-sparks-#{env}] #{@solar_feed_type} Import for #{@import_subject} #{@error ? :failed : :completed}"
  end
end
