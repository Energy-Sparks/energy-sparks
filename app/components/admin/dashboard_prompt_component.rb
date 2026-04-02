# frozen_string_literal: true

module Admin
  class DashboardPromptComponent < ApplicationComponent
    attr_reader :user

    renders_one :title

    def initialize(user:, **_kwargs)
      super
      @user = user
    end

    def prompt_for_issues_review?
      user.owned_issues.by_review_date.first.review_date <= Date.current
    end

    def issues_count
      user.owned_issues.where.not(review_date: Date.current..).count
    end

    def add_prompt(list:, status:, icon:, check: true, id: nil, link: nil, path: nil) # rubocop:disable Metrics/ParameterLists, Lint/UnusedMethodArgument
      return unless check

      list.with_prompt id: id, status: status, icon: icon do # rubocop:disable Style/ExplicitBlockArgument
        yield
      end
    end
  end
end
