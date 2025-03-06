# frozen_string_literal: true

class DashboardInsightsComponent < ApplicationComponent
  include TargetsHelper
  include DashboardAlerts

  attr_reader :school, :progress_summary, :user, :audience

  def initialize(school:, audience: :adult, progress_summary: nil, user: nil, id: nil, classes: '')
    super(id: id, classes: classes)
    @school = school
    @audience = audience
    @user = user
    @progress_summary = progress_summary
  end

  def alerts
    latest_alerts = @school.latest_dashboard_alerts
    @alerts ||= setup_alerts(adult? ? latest_alerts.management_dashboard : latest_alerts.pupil_dashboard, content_field)
  end

  def content_field
    adult? ? :management_dashboard_title : :pupil_dashboard_title
  end

  def adult?
    @audience == :adult
  end

  def data_enabled?
    return true if user.present? && user.admin?
    @school.data_enabled?
  end

  # display the alert column if the the school is data enabled and we have any content for that column
  def displaying_alerts?
    data_enabled? && (alerts.any? || any_passing_targets? || any_failing_targets?)
  end

  def any_passing_targets?
    reportable_progress?(@progress_summary) && @progress_summary.any_passing_targets?
  end

  def any_failing_targets?
    reportable_progress?(@progress_summary) && @progress_summary.any_failing_targets?
  end
end
