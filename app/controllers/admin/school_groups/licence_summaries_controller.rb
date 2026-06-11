# frozen_string_literal: true

module Admin
  module SchoolGroups
    class LicenceSummariesController < AdminController
      load_and_authorize_resource :school_group

      layout 'group_settings'

      def show
        @current_year = Calendar.default_national.current_academic_year
        @next_year = Calendar.default_national.current_academic_year.next_year

        respond_to do |format|
          format.html { render :show }
          format.text do
            render(::Commercial::RangeFundingSummaryComponent.new(
                     school_group: @school_group,
                     range: @next_year.start_date..@next_year.end_date,
                     range_label: 'next academic year'
                   ),
                   content_type: 'text/plain')
          end
        end
      end
    end
  end
end
