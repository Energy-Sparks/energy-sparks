# frozen_string_literal: true

module Admin
  module Reports
    class ActivitiesController < AdminController
      include Pagy::Backend

      def index # rubocop:disable Metrics/AbcSize
        @activities = Activity.includes(:observations,
                                        :school,
                                        :activity_type,
                                        observations: :created_by,
                                        school: :school_group,
                                        rich_text_description: { embeds_attachments: :blob })
                              .recorded_in_last_year.order(created_at: :desc)
        @activities = @activities.for_school_group(params[:school_group]) if params[:school_group].present?
        @activities = @activities.for_admin(params[:admin]) if params[:admin].present?
        @activities = @activities.for_school(params[:school]) if params[:school].present?
        @activities = @activities.for_user_role(params[:user_role]) if params[:user_role].present?
        @activities = @activities.search(params[:search]) if params[:search].present?

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
