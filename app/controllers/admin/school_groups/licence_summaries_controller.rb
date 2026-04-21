# frozen_string_literal: true

module Admin
  module SchoolGroups
    class LicenceSummariesController < AdminController
      load_and_authorize_resource :school_group

      layout 'group_settings'

      def show
        @academic_year = Calendar.default_national.current_academic_year
      end
    end
  end
end
