# frozen_string_literal: true

class SolarEdgeMailer < LocaleMailer
  def request_connection
    @school = params[:school]
    @title = @school.name
    make_bootstrap_mail(to: to_field(params[:users], params[:email]))
  end

  def notify_admin(installation)
    @installation = installation
    @title = @installation.school.name
    email = @installation.school&.default_issues_admin_user&.email || 'operations@energysparks.uk'
    make_bootstrap_mail(to: email, subject: admin_subject("SolarEdge Site Connected for #{@installation.school.name}"))
  end

  private

  def to_field(users, email)
    to_field = []
    to_field << user_emails(users) if users&.any?
    to_field << email if email.present?
    to_field
  end
end
