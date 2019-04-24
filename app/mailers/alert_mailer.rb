class AlertMailer < ApplicationMailer
  add_template_helper(AlertsChartsHelper)

  def alert_email
    @email_address = params[:email_address]
    @events = params[:events]
    @school = params[:school]
    @unsubscribe_emails = User.where(school: @school, role: :school_admin).pluck(:email).join(', ')

    @alert_content = @events.map do |event|
      TemplateInterpolation.new(
        event.content_version,
        with_objects: {
          alert: event.alert,
          find_out_more: event.associated_find_out_more
        },
      ).interpolate(
        :email_content, :email_title,
        with: event.alert.template_variables
      )
    end

    make_bootstrap_mail(to: @email_address, subject: 'Energy Sparks alerts')
  end
end
