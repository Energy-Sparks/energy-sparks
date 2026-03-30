# frozen_string_literal: true

module Admin
  class DashboardPromptComponent < ApplicationComponent
    attr_reader :user

    renders_one :title

    def initialize(user:, **_kwargs)
      super
      @user = user
    end

    def prompt_for_issues_renewal?
      true
    end

    def add_prompt(list:, status:, icon:, check: true, id: nil, link: nil, path: nil) # rubocop:disable Metrics/ParameterLists, Lint/UnusedMethodArgument
      return unless check

      list.with_prompt id: id, status: status, icon: icon do # rubocop:disable Style/ExplicitBlockArgument
        yield
      end
    end
  end
end
