# frozen_string_literal: true

module Dashboards
  class GroupLearnMoreComponent < ApplicationComponent
    attr_reader :schools, :school_group

    def initialize(school_group:, schools:, **_kwargs)
      super
      @school_group = school_group
      @schools = schools
    end

    def data_enabled_schools?
      schools.data_enabled.any?
    end

    def render?
      schools.any?
    end
  end
end
