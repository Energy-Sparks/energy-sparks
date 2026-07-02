# frozen_string_literal: true

module Admin
  module Reports
    class ActivitiesController < AdminController
      include Pagy::Backend

      def index # rubocop:disable Metrics/AbcSize
        filters = filter_params
        @activities = Activity.includes(:observations,
                                        :school,
                                        :activity_type,
                                        observations: :created_by,
                                        school: :school_group,
                                        rich_text_description: { embeds_attachments: :blob })
                              .recorded_in_last_year.order(created_at: :desc)
        @activities = @activities.for_school_group(filters[:school_group]) if filters[:school_group].present?
        @activities = @activities.for_admin(filters[:admin]) if filters[:admin].present?
        @activities = @activities.for_school(filters[:school]) if filters[:school].present?
        @activities = @activities.for_user_role(filters[:user_role]) if filters[:user_role].present?
        @activities = @activities.search(filters[:search]) if filters[:search].present?

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

      def filter_params
        params.permit(:format, :search, :school_group, :admin, :school, :user_role)
      end
    end
  end
end
