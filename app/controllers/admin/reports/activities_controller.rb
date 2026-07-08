# frozen_string_literal: true

module Admin
  module Reports
    class ActivitiesController < AdminController
      include Pagy::Backend
      include ActivityInterventionFilterable

      def index
        @activities = Activity.includes(:observations,
                                        :school,
                                        :activity_type,
                                        observations: :created_by,
                                        school: :school_group,
                                        rich_text_description: { embeds_attachments: :blob })
                              .recorded_in_last_year.order(created_at: :desc)
        @activities = apply_filters(@activities)

        format
      end

      def format
        respond_to do |format|
          format.html do
            @pagy, @activities = pagy(@activities)
          end
          format.csv do
            send_data @activities.to_csv,
                      filename: EnergySparks::Filenames.csv('activities')
          end
        end
      end
    end
  end
end
