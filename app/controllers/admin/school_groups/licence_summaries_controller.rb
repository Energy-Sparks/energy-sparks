# frozen_string_literal: true

module Admin
  module SchoolGroups
    class LicenceSummariesController < AdminController
      include SchoolGroupBreadcrumbs

      load_and_authorize_resource :school_group

      before_action :breadcrumbs
      before_action :set_academic_years, only: :show

      layout 'group_settings'

      def show
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

      private

      def breadcrumbs
        build_breadcrumbs([{ name: t('school_groups.titles.licence_summaries') }])
      end

      # Up until March show previous and current academic years.
      # From March show current and next academic years
      def set_academic_years
        this_year = Calendar.default_national.current_academic_year
        if in_september_to_february?
          @current_year = this_year.previous_year
          @next_year = this_year
        else
          @current_year = this_year
          @next_year = this_year.next_year
        end
      end

      def in_september_to_february?
        (9..12).cover?(Time.zone.today.month) || (1..2).cover?(Time.zone.today.month)
      end
    end
  end
end
