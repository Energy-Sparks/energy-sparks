# frozen_string_literal: true

module Admin
  class DashboardPromptComponent < ApplicationComponent
    attr_reader :user

    renders_one :title

    def initialize(user:, **_kwargs)
      super
      @user = user
    end

    def dashboard_prompts
      [
        { id: 'overdue-issues', check: prompt_for_issues_overdue?, status: :negative, icon: 'exclamation',
          link: 'View Issues',
          path: admin_dashboard_issues_path(dashboard_id: @user, user: @user, review_date: 'review_overdue'),
          content: "You have #{overdue_issues_count} issues overdue for review" },
        { id: 'lagging-data-sources', check: prompt_for_lagging_data_sources?, status: :negative,
          icon: 'exclamation', link: 'View Data Sources', path: admin_dashboard_data_sources_path(dashboard_id: @user),
          content: "You have #{lagging_data_sources_count} lagging data sources" },
        { id: 'missing-data-feeds', check: prompt_for_missing_data_feed_readings?, status: :negative,
          icon: 'exclamation', link: 'View AMR Data Feed Configurations',
          path: admin_dashboard_amr_data_feed_configs_path(dashboard_id: @user),
          content: "You have #{missing_data_feed_readings_count} amr data feed configurations with missing data" },
        { id: 'weekly-issues', check: prompt_for_weekly_issues?, status: :neutral, icon: 'magnifying-glass',
          link: 'View Issues',
          path: admin_dashboard_issues_path(dashboard_id: @user, user: @user, review_date: 'review_next_week'),
          content: "You have #{weekly_issues_count} issues due for review in the next week" },
        { id: 'school-activation', check: prompt_for_school_activation?, status: :neutral, icon: 'school',
          link: 'View Activations', path: admin_activations_path,
          content: "You have #{school_activations_count} schools awaiting activation" }
      ]
    end

    def prompt_for_issues_overdue?
      true unless overdue_issues_count.nil? || overdue_issues_count.zero?
    end

    def prompt_for_weekly_issues?
      true unless weekly_issues_count.nil? || weekly_issues_count.zero?
    end

    def prompt_for_school_activation?
      true unless school_activations_count.nil? || school_activations_count.zero?
    end

    def prompt_for_lagging_data_sources?
      true unless lagging_data_sources_count.nil? || lagging_data_sources_count.zero?
    end

    def prompt_for_missing_data_feed_readings?
      true unless missing_data_feed_readings_count.nil? || missing_data_feed_readings_count.zero?
    end

    def overdue_issues_count
      @overdue_issues_count ||= user.owned_issues.where.not(review_date: Date.current..).count
    end

    def weekly_issues_count
      @weekly_issues_count ||= user.owned_issues.where(review_date: Date.current...(Date.current + 7)).count
    end

    def school_activations_count
      @school_activations_count ||= SchoolGroup.organisation_groups.where(default_issues_admin_user: user).by_name
                                               .count(&:has_schools_awaiting_activation?)
    end

    def lagging_data_sources_count
      @lagging_data_sources_count ||= DataSource.where(owned_by: user).find_each.count(&:exceeded_alert_threshold?)
    end

    def missing_data_feed_readings_count
      @missing_data_feed_readings_count ||= AmrDataFeedConfig.enabled
                                                             .where(owned_by: @user)
                                                             .where.not(source_type: :manual)
                                                             .where.not(missing_reading_window: nil)
                                                             .stopped_feeds
                                                             .count
    end

    private

    def add_prompt(list:, status:, icon:, check: true, id: nil, link: nil, path: nil) # rubocop:disable Metrics/ParameterLists
      return unless check

      list.with_prompt id: id, status: status, icon: icon do |p|
        yield
        p.with_link { helpers.link_to link, path } if link
      end
    end
  end
end
