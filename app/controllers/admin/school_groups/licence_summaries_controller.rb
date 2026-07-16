# frozen_string_literal: true

module Admin
  module SchoolGroups
    class LicenceSummariesController < AdminController
      include SchoolGroupBreadcrumbs

      load_and_authorize_resource :school_group

      before_action :breadcrumbs

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

      def breadcrumbs
        build_breadcrumbs([{ name: t('school_groups.titles.licence_summaries') }])
      end
    end
  end
end
