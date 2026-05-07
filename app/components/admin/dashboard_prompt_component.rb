# frozen_string_literal: true

module Admin
  class DashboardPromptComponent < ApplicationComponent # rubocop:disable Metrics/ClassLength
    attr_reader :user

    renders_one :title

    def initialize(user:, **_kwargs)
      super
      @user = user
    end

    def dashboard_prompts # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      [
        { id: 'overdue-issues', check: prompt_for_issues_overdue?, status: :negative, icon: 'exclamation',
          link: 'View Issues',
          path: admin_dashboard_issues_path(dashboard_id: @user, user: @user, review_date: 'review_overdue'),
          content: "You have #{overdue_issues_count} issues overdue for review" },
        { id: 'lagging-data-sources', check: prompt_for_lagging_data_sources?, status: :negative,
          icon: 'plug-circle-exclamation', link: 'View Data Sources',
          path: admin_dashboard_data_sources_path(dashboard_id: @user),
          content: "You have #{lagging_data_sources_count} lagging data sources" },
        { id: 'missing-data-feeds', check: prompt_for_missing_data_feed_readings?, status: :negative,
          icon: 'plug-circle-exclamation', link: 'View AMR Data Feed Configurations',
          path: admin_dashboard_amr_data_feed_configs_path(dashboard_id: @user),
          content: "You have #{missing_data_feed_readings_count} amr data feed configurations with missing data" },
        { id: 'weekly-issues', check: prompt_for_weekly_issues?, status: :neutral, icon: 'magnifying-glass',
          link: 'View Issues',
          path: admin_dashboard_issues_path(dashboard_id: @user, user: @user, review_date: 'review_next_week'),
          content: "You have #{weekly_issues_count} issues due for review in the next week" },
        { id: 'school-activation', check: prompt_for_school_activation?, status: :neutral, icon: 'school-lock',
          link: 'View Activations', path: admin_dashboard_activations_path(dashboard_id: @user),
          content: "You have #{school_activations_count} schools awaiting activation" },
        { id: 'school-onboarding', check: prompt_for_school_onboarding?, status: :neutral, icon: 'school-flag',
          link: 'View Onboardings', path: admin_dashboard_school_onboardings_path(dashboard_id: @user),
          content: "You have #{school_onboardings_count} schools that have not yet completed onboarding" },
        { id: 'low-engaged-schools', check: prompt_for_low_engaged_schools?, status: :neutral,
          icon: 'school-circle-xmark', link: 'View Engaged Groups',
          path: admin_dashboard_engaged_groups_path(dashboard_id: @user),
          content: "You have #{low_engaged_schools_count} groups with engagement below 50%" },
        { id: 'missing-alert-contacts', check: prompt_for_missing_alert_contacts?,
          status: :neutral, icon: 'address-book', link: 'View Schools',
          path: admin_dashboard_missing_alert_contacts_path(dashboard_id: @user),
          content: "You have #{missing_alert_contacts_count} schools that are missing alert contacts" }
      ]
    end

    private

    def prompt_for_issues_overdue?
      true unless overdue_issues_count.nil? || overdue_issues_count.zero?
    end

    def prompt_for_weekly_issues?
      true unless weekly_issues_count.nil? || weekly_issues_count.zero?
    end

    def prompt_for_school_activation?
      true unless school_activations_count.nil? || school_activations_count.zero?
    end

    def prompt_for_school_onboarding?
      true unless school_onboardings_count.nil? || school_onboardings_count.zero?
    end

    def prompt_for_lagging_data_sources?
      true unless lagging_data_sources_count.nil? || lagging_data_sources_count.zero?
    end

    def prompt_for_missing_data_feed_readings?
      true unless missing_data_feed_readings_count.nil? || missing_data_feed_readings_count.zero?
    end

    def prompt_for_low_engaged_schools?
      true unless low_engaged_schools_count.nil? || low_engaged_schools_count.zero?
    end

    def prompt_for_missing_alert_contacts?
      true unless missing_alert_contacts_count.nil? || missing_alert_contacts_count.zero?
    end

    def overdue_issues_count
      @overdue_issues_count ||= user.owned_issues.where.not(review_date: Date.current..).count
    end

    def weekly_issues_count
      @weekly_issues_count ||= user.owned_issues.where(review_date: Date.current...(Date.current + 7)).count
    end

    def school_activations_count
      @school_activations_count ||= School.joins(:organisation_group)
                                          .where(organisation_group: { default_issues_admin_user: user })
                                          .awaiting_activation
                                          .count
    end

    def school_onboardings_count
      @school_onboardings_count ||= SchoolOnboarding.incomplete
                                                    .joins(:school_group)
                                                    .where(school_group: { default_issues_admin_user: user })
                                                    .count { |onboarding| onboarding.has_event?(:email_sent) }
    end

    def lagging_data_sources_count
      @lagging_data_sources_count ||= DataSource.where(owned_by: user).find_each.count(&:exceeded_alert_threshold?)
    end

    def missing_data_feed_readings_count
      @missing_data_feed_readings_count ||= AmrDataFeedConfig.enabled
                                                             .where(owned_by: user)
                                                             .where.not(source_type: :manual)
                                                             .where.not(missing_reading_window: nil)
                                                             .stopped_feeds
                                                             .count
    end

    def low_engaged_schools_count
      engagement_threshold = 0.5
      @low_engaged_schools_count ||= SchoolGroup.organisation_groups
                                                .where(default_issues_admin_user: @user)
                                                .count_active_schools
                                                .count_engaged_schools
                                                .where('COALESCE(active.count, 0) > 0')
                                                .where('COALESCE(engaged.count, 0) * 1.0 < ? * active.count',
                                                       engagement_threshold)
                                                .count
    end

    def missing_alert_contacts_count
      @missing_alert_contacts_count ||= School.joins(:school_group)
                                              .where(school_group: { default_issues_admin_user: user })
                                              .visible
                                              .missing_alert_contacts
                                              .count
    end

    def add_prompt(list:, status:, icon:, check: true, id: nil, link: nil, path: nil) # rubocop:disable Metrics/ParameterLists
      return unless check

      list.with_prompt id: id, status: status, icon: icon do |p|
        yield
        p.with_link { helpers.link_to link, path } if link
      end
    end
  end
end
