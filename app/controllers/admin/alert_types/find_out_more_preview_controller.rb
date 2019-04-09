module Admin
  module AlertTypes
    class FindOutMorePreviewController < AdminController
      load_and_authorize_resource :alert_type

      def show
        @alert = @alert_type.alerts.rating_between(from_parameter, to_parameter).order(created_at: :desc).first
        if @alert
          load_find_out_more_requirements
          render 'schools/find_out_more/show', layout: nil
        else
          render 'no_alert', layout: nil
        end
      end

    private

      def load_find_out_more_requirements
        # TODO: match activity types ordering
        @activity_types = @alert_type.ordered_activity_types.limit(3)
        @school = @alert.school
        content_version = FindOutMoreTypeContentVersion.new(content_params.fetch(:content))
        @content = TemplateInterpolation.new(content_version).interpolate(:page_title, :page_content, with: @alert.template_variables)
        @charts = @alert.charts
        @tables = @alert.tables
      end

      def from_parameter
        from = params.fetch(:find_out_more_type, {})[:rating_from]
        from.blank? ? 0 : from
      end

      def to_parameter
        to = params.fetch(:find_out_more_type, {})[:rating_to]
        to.blank? ? 0 : to
      end

      def content_params
        params.require(:find_out_more_type).permit(
          content: [:dashboard_title, :page_title, :page_content, :colour]
        )
      end
    end
  end
end
