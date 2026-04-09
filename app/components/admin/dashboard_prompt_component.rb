# frozen_string_literal: true

module Admin
  class DashboardPromptComponent < ApplicationComponent
    attr_reader :user

    renders_one :title

    def initialize(user:, **_kwargs)
      super
      @user = user
      @overdue_issues = 0
      @weekly_issues = 0
      @school_activations = 0
      @lagging_data_sources = 0
      @missing_data_feed_readings = 0
    end

    def dashboard_prompts
      [
        { id: 'overdue-issues', check: prompt_for_issues_overdue?, status: :negative, icon: 'exclamation',
          link: 'View Issues', path: admin_issues_path(user: @user),
          content: "You have #{@overdue_issues} issues overdue for review" },
        { id: 'lagging-data-sources', check: prompt_for_lagging_data_sources?, status: :negative,
          icon: 'exclamation', link: 'View Data Sources', path: admin_data_sources_path,
          content: "You have #{@lagging_data_sources} lagging data sources" },
        { id: 'missing-data-feeds', check: prompt_for_missing_data_feed_readings?, status: :negative,
          icon: 'exclamation', link: 'View AMR Data Feed Configurations', path: admin_amr_data_feed_configs_path,
          content: "You have #{@missing_data_feed_readings} amr data feed configurations with missing data" },
        { id: 'weekly-issues', check: prompt_for_weekly_issues?, status: :neutral, icon: 'magnifying-glass',
          link: 'View Issues', path: admin_issues_path(user: @user),
          content: "You have #{@weekly_issues} issues due for review in the next week" },
        { id: 'school-activation', check: prompt_for_school_activation?, status: :neutral, icon: 'school',
          link: 'View Activations', path: admin_activations_path,
          content: "You have #{@school_activations} schools awaiting activation" }
      ]
    end

    def prompt_for_issues_overdue?
      overdue_issues_count
      @overdue_issues.positive?
    end

    def prompt_for_weekly_issues?
      weekly_issues_count
      @weekly_issues.positive?
    end

    def prompt_for_school_activation?
      schools_awaiting_activation_count
      @school_activations.positive?
    end

    def prompt_for_lagging_data_sources?
      lagging_data_sources_count
      @lagging_data_sources.positive?
    end

    def prompt_for_missing_data_feed_readings?
      missing_data_feed_readings_count
      @missing_data_feed_readings.positive?
    end

    def overdue_issues_count
      @overdue_issues = user.owned_issues.where.not(review_date: Date.current..).count
    end

    def weekly_issues_count
      @weekly_issues = user.owned_issues.where(review_date: Date.current...(Date.current + 7)).count
    end

    def schools_awaiting_activation_count
      @school_activations = SchoolGroup.organisation_groups.where(default_issues_admin_user: user).by_name
                                       .count(&:has_schools_awaiting_activation?)
    end

    def lagging_data_sources_count
      @lagging_data_sources = DataSource.where(owned_by: user).find_each.count(&:exceeded_alert_threshold?)
    end

    def missing_data_feed_readings_count
      now = Time.current
      @missing_data_feed_readings = AmrDataFeedConfig.enabled
                                                     .where(owned_by: @user)
                                                     .where.not(source_type: :manual)
                                                     .where.not(missing_reading_window: nil)
                                                     .count do |config|
        latest = config.amr_data_feed_readings.maximum(:updated_at)
        since_latest = latest && (now - latest)
        [config] if latest && since_latest > config.missing_reading_window.days
      end
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
