class N3rgyReloadJobMailer < ApplicationMailer
  helper :application, :issues
  layout 'admin_mailer'

  def complete
    to, @meter, @import_log = params.values_at(:to, :meter, :import_log)
    mail(to:, subject: "[energy-sparks-#{env}] Reload of Meter #{@meter.name} for #{@meter.school.name} complete")
  end
end