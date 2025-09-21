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

    def i18n_scope
      'components.dashboards.group_learn_more'
    end

    def title
      if data_enabled?
        I18n.t('title', scope: i18n_scope)
      else
        I18n.t('schools.show.coming_soon')
      end
    end

    def intro
      if data_enabled?
        I18n.t('intro', scope: i18n_scope)
      else
        I18n.t('intro_no_data', scope: i18n_scope)
      end
    end
  end
end
