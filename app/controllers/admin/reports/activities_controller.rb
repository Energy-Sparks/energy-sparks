# frozen_string_literal: true

module Admin
  module Reports
    class ActivitiesController < AdminController
      include Pagy::Backend
      include RecordingFilterable

      def index
        @activities = fetch_activities

        respond_to do |format|
          format.html do
            @pagy, @activities = pagy(@activities)
          end

          format.csv do
            @headers = headers
            response.headers['Content-Type'] = 'text/csv'
            response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
            render partial: 'table'
          end
        end
      end

      private

      def fetch_activities
        activities = Activity.includes(
          :observations,
          :school,
          :activity_type,
          observations: :created_by,
          school: :school_group,
          rich_text_description: { embeds_attachments: :blob }
        )
                             .recorded_in_last_year
                             .order(created_at: :desc)
        activities = apply_filters(activities)
        activities = apply_dashboard_filters(activities) if @dashboard_user
        activities
      end

      def filename
        EnergySparks::Filenames.csv('activities')
      end

      def headers
        ['School Group', 'Admin', 'School', 'User', 'User Role', 'User Staff Role', 'Recorded', 'Happened', 'Title',
         'Images?']
      end
    end
  end
end
