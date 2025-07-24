class CampaignMailer < LocaleMailer
  def notify_admin
    @request_type, @contact, @party, @opportunity = params.values_at(:request_type, :contact, :party, :opportunity)
    make_bootstrap_mail(to: 'hello@energysparks.uk', subject: notify_admin_subject(@contact[:organisation], @request_type))
  end

  def send_information_school
    @contact = params[:contact]
    @title = I18n.t('campaigns.school_info.title')
    make_bootstrap_mail(to: @contact[:email], subject: I18n.t('campaign_mailer.send_information_school.subject'))
  end

  def send_information_group
    @contact = params[:contact]
    @contact_org_type = contact_org_type(@contact)
    @title = I18n.t('campaign_mailer.send_information_school.subject')
    make_bootstrap_mail(to: @contact[:email], subject: I18n.t('campaign_mailer.send_information_school.subject'))
  end

  def school_demo
    @contact = params[:contact]
    @title = I18n.t('campaign_mailer.school_demo.subject')
    make_bootstrap_mail(to: @contact[:email], subject: I18n.t('campaign_mailer.school_demo.subject'))
  end

  private

  def notify_admin_subject(organisation, request_type)
    "[energy-sparks-#{env}] Campaign form: #{organisation} - #{request_type.to_s.humanize}"
  end

  def contact_org_type(contact)
    return :multi_academy_trust if contact[:org_type].include?(LandingPagesController::TRUST)
    return :local_authority if contact[:org_type].include?(LandingPagesController::LA)
    return :school
  end
end
