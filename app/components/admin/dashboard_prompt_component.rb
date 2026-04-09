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
        { id: 'overdue-issues', check: prompt_for_issues_overdue?, status: :negative, icon: 'circle-exclamation',
          link: 'View Issues', path: admin_issues_path(user: @user),
          content: "You have #{overdue_issues_count} issues overdue for review" },
        { id: 'lagging-data-sources', check: prompt_for_lagging_data_sources?, status: :negative,
          icon: 'circle-exclamation', link: 'View Data Sources', path: admin_data_sources_path,
          content: "You have #{lagging_data_sources_count} lagging data sources" },
        # { id: 'data-feeds-without-data', check: prompt_for_issues_overdue, status: :negative,
        #   icon: 'circle-exclamation', link: 'View Issues', path: admin_issues_path(user: @user) },
        { id: 'weekly-issues', check: prompt_for_weekly_issues?, status: :neutral, icon: 'magnifying-glass',
          link: 'View Issues', path: admin_issues_path(user: @user),
          content: "You have #{weekly_issues_count} issues due for review in the next week" },
        { id: 'school-activation', check: prompt_for_school_activation?, status: :neutral, icon: 'school',
          link: 'Activations', path: admin_activations_path,
          content: "You have #{schools_awaiting_activation_count} schools awaiting activation" }
      ]
    end

    def prompt_for_issues_overdue?
      (user.owned_issues.by_review_date.first&.review_date || Date.current) < Date.current
    end

    def prompt_for_weekly_issues?
      user.owned_issues.where(review_date: Date.current...(Date.current + 7)).first
    end

    def prompt_for_school_activation?
      SchoolGroup.organisation_groups.where(default_issues_admin_user: user)
                 .by_name.find(&:has_schools_awaiting_activation?)
    end

    def prompt_for_lagging_data_sources?
      DataSource.where(owned_by_id: user.id).find(&:exceeded_alert_threshold?)
    end

    def overdue_issues_count
      user.owned_issues.where.not(review_date: Date.current..).count
    end

    def weekly_issues_count
      user.owned_issues.where(review_date: Date.current...(Date.current + 7)).count
    end

    def schools_awaiting_activation_count
      SchoolGroup.organisation_groups.where(default_issues_admin_user: user).by_name
                 .count(&:has_schools_awaiting_activation?)
    end

    def lagging_data_sources_count
      DataSource.where(owned_by_id: user.id).find_each.count(&:exceeded_alert_threshold?)
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
