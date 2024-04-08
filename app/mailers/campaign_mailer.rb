class CampaignMailer < LocaleMailer
  def notify_admin
    @request_type, @contact, @party, @opportunity = params.values_at(:request_type, :contact, :party, :opportunity)
    make_bootstrap_mail(to: 'hello@energysparks.uk', subject: notify_admin_subject(@contact[:organisation], @request_type))
  end

  def send_information
    @contact = params[:contact]
    @group = trust_or_local_authority?(@contact)
    @title = I18n.t('campaign_mailer.send_information.subject')
    make_bootstrap_mail(to: @contact[:email], subject: I18n.t('campaign_mailer.send_information.subject'))
  end

  private

  def env
    ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
  end

  def notify_admin_subject(organisation, request_type)
    "[energy-sparks-#{env}] Campaign form: #{organisation} - #{request_type.to_s.humanize}"
  end

  def trust_or_local_authority?(contact)
    contact[:org_type].any? {|t| LandingPagesController::GROUP_TYPES.include? t }
  end
end
