class CampaignMailer < LocaleMailer
  def notify_admin
    @request_type, @contact, @party, @opportunity = params.values_at(:request_type, :contact, :party, :opportunity)
    make_bootstrap_mail(to: 'hello@energysparks.uk', subject: subject(@contact[:organisation], @request_type))
  end

  private

  def env
    ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
  end

  def subject(organisation, request_type)
    "[energy-sparks-#{env}] Campaign form: #{organisation} - #{request_type.to_s.humanize}"
  end
end
