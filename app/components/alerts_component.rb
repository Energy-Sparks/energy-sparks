# frozen_string_literal: true

class AlertsComponent < PromptListComponent
  attr_reader :school, :show_links, :user, :email

  include AdvicePageHelper

  def initialize(school:, dashboard_alerts:, alert_types: nil, audience: :adult, show_links: true, id: nil,
                 classes: '', user: nil, content_field: nil, email: false)
    super(id: id, classes: classes)
    @school = school
    @dashboard_alerts = dashboard_alerts
    @alert_types = alert_types
    @show_links = show_links
    @audience = audience
    @user = user
    @content_field = content_field
    @email = email
    # debugger
  end

  def alerts
    # debugger
    @alerts ||= dashboard_alerts_for(@alert_types)
  end

  def render?
    prompts? || alerts.any?
  end

  def content_field
    return @content_field if @content_field

    @audience == :adult ? :management_dashboard_title : :pupil_dashboard_title
  end

  def dashboard_alerts_for(alert_types)
    return @dashboard_alerts unless alert_types.present?
    alert_type_ids = alert_types.map(&:id)
    @dashboard_alerts.select { |dashboard_alert| alert_type_ids.include?(dashboard_alert.alert.alert_type_id) }
  end
end
