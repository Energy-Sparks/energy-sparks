module Dashboards
  class GroupInsightsComponent < ApplicationComponent
    attr_reader :school_group, :user

    def initialize(school_group:, user:, **kwargs)
      super
      @school_group = school_group
      @user = user
    end

    def showing_alerts?
      alerts_component.summarised_alerts.any?
    end

    def showing_reminders?
      reminders_component.render?
    end

    def reminders_component
      @reminders_component ||= Dashboards::GroupRemindersComponent.new(school_group: school_group, user: user, id: 'group-reminders')
    end

    def alerts_component
      @alerts_component ||= Dashboards::GroupAlertsComponent.new(school_group: school_group, id: 'group-alerts')
    end

    def render?
      showing_reminders? || showing_alerts?
    end
  end
end
