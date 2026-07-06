# frozen_string_literal: true

module Admin
  module Reports
    class InterventionsController < AdminController
      include Pagy::Backend

      def index # rubocop:disable Metrics/AbcSize
        @observations = Observation.includes(:school,
                                             :intervention_type,
                                             :created_by,
                                             school: :school_group,
                                             rich_text_description: { embeds_attachments: :blob })
                                   .intervention
                                   .recorded_in_last_year.order(created_at: :desc)
        @observations = @observations.for_school_group(params[:school_group]) if params[:school_group].present?
        @observations = @observations.for_admin(params[:admin]) if params[:admin].present?
        @observations = @observations.for_school(params[:school]) if params[:school].present?
        @observations = @observations.for_user_role(params[:user_role]) if params[:user_role].present?

        format
      end

      def format
        respond_to do |format|
          format.html do
            @pagy, @observations = pagy(@observations)
          end
          format.csv do
            send_data @observations.to_csv,
                      filename: EnergySparks::Filenames.csv('interventions')
          end
        end
      end
    end
  end
end
