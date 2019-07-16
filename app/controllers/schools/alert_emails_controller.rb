# frozen_string_literal: true

module Schools
  class AlertEmailsController < ApplicationController
    def create
      school = School.find(params[:school_id])
      authorize! :send_alert_emails, school

      Alerts::GenerateEmailNotifications.new.perform
      redirect_back fallback_location: school_alert_subscription_events_path(school), notice: 'Emails sent'
    rescue => e
      Rollbar.error(e)
      redirect_back fallback_location: school_alert_subscription_events_path(school), alert: 'Email sending failed'
    end
  end
end
