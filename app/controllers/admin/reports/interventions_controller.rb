# frozen_string_literal: true

module Admin
  module Reports
    class InterventionsController < AdminController
      include Pagy::Backend
      include RecordingFilterable

      def index
        @observations = Observation.includes(:school,
                                             :intervention_type,
                                             :created_by,
                                             school: :school_group,
                                             rich_text_description: { embeds_attachments: :blob })
                                   .intervention
                                   .recorded_in_last_year.order(created_at: :desc)
        @observations = apply_filters(@observations)
        format
      end

      def format
        respond_to do |format|
          format.html do
            @pagy, @observations = pagy(@observations)
          end
          format.csv do
            @headers = headers
            filename = EnergySparks::Filenames.csv('interventions')
            response.headers['Content-Type'] = 'text/csv'
            response.headers['Content-Disposition'] = "attachment; filename=#{filename}"
            render partial: 'table'
          end
        end
      end

      private

      def headers
        ['School Group', 'Admin', 'School', 'User', 'User Role', 'User Staff Role', 'Recorded', 'Happened',
         'Intervention Type', 'Images?']
      end
    end
  end
end
