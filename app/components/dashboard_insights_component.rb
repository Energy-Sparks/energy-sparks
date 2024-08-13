# frozen_string_literal: true

class DashboardInsightsComponent < ApplicationComponent
  attr_reader :school, :alerts, :progress_summary

  def initialize(school:, audience: :adult, alerts: [], progress_summary: nil, user: nil, id: nil, classes: '')
    super(id: id, classes: classes)
    @school = school
    @audience = audience
    @user = user
    @alerts = alerts
    @progress_summary = progress_summary
  end
end
