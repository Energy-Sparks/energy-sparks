# frozen_string_literal: true

module Admin
  module SchoolGroups
    class LicenceSummariesController < AdminController
      load_and_authorize_resource :school_group

      layout 'group_settings'

      def show
        @current_year = Calendar.default_national.current_academic_year
        @next_year = Calendar.default_national.current_academic_year.next_year
        @selected_year = if params[:academic_year].present?
                           AcademicYear.find(params.expect(:academic_year))
                         else
                           @current_year
                         end
      end
    end
  end
end
