class BillRequestMailer < LocaleMailer
  def request_bill
    @school = params[:school]
    @title = @school.name
    @electricity_meters = params[:electricity_meters]
    @gas_meters = params[:gas_meters]
    make_bootstrap_mail(to: user_emails(params[:users]))
  end

  def notify_admin
    @school = params[:school]
    @consent_document = params[:consent_document]
    environment_identifier = ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
    @updated = params[:updated]
    prefix = "[energy-sparks-#{environment_identifier}]"
    subject = @updated ? "#{prefix} #{@school.name} has updated a bill" : "#{prefix} #{@school.name} has uploaded a bill"
    make_bootstrap_mail(to: 'operations@energysparks.uk', subject: subject)
  end
end
