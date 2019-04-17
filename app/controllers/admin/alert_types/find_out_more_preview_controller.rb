module Admin
  module AlertTypes
    class FindOutMorePreviewController < AdminController
      load_and_authorize_resource :alert_type

      def show
        @alert = @alert_type.alerts.rating_between(from_parameter, to_parameter).order(created_at: :desc).first
        if @alert
          load_rating_requirements
          render 'schools/find_out_more/show', layout: nil
        else
          render 'no_alert', layout: nil
        end
      end

    private

      def load_rating_requirements
        # TODO: match activity types ordering
        @activity_types = @alert_type.ordered_activity_types.limit(3)
        @school = @alert.school
        content_version = AlertTypeRatingContentVersion.new(content_params.fetch(:content))
        @content = TemplateInterpolation.new(content_version).interpolate(:page_title, :page_content, with: @alert.template_variables)
        @charts = @alert.charts
        @tables = @alert.tables
      end

      def from_parameter
        from = params.fetch(:alert_type_rating, {})[:rating_from]
        from.blank? ? 0 : from
      end

      def to_parameter
        to = params.fetch(:alert_type_rating, {})[:rating_to]
        to.blank? ? 10 : to
      end

      def content_params
        params.require(:alert_type_rating).permit(
          content: [:page_title, :page_content, :colour]
        )
      end
    end
  end
end
