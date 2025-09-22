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
      schools = @school_group.schools.by_name
      (user&.admin? && schools.process_data) || schools.data_enabled
    end

    def data_enabled?
      schools.any?
    end
  end
end
