# frozen_string_literal: true

module Dashboards
  class GroupLearnMoreComponent < ApplicationComponent
    attr_reader :schools, :school_group

    def initialize(school_group:, schools:, **_kwargs)
      super
      @school_group = school_group
      @schools = schools.data_enabled
      add_classes('data-disabled p-4 rounded-lg mb-4') unless data_enabled?
    end

    def data_enabled?
      schools.any?
    end
  end
end
