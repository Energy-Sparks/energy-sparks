# frozen_string_literal: true

module Dashboards
  class GroupLearnMoreComponent < ApplicationComponent
    attr_reader :school_group, :user

    def initialize(school_group:, user:, **kwargs)
      super
      @school_group = school_group
      @user = user
    end

    def schools
      user&.admin? && @school_group.schools.process_data || school_group.schools.data_enabled
    end

    def data_enabled?
      schools.any?
    end

    def title
      if data_enabled?
        I18n.t('components.dashboards.group_learn_more.title')
      else
        I18n.t('schools.show.coming_soon')
      end
    end

    def intro
      if data_enabled?
        I18n.t('components.dashboards.group_learn_more.intro')
      else
        I18n.t('components.dashboards.group_learn_more.intro_no_data')
      end
    end
  end
end
