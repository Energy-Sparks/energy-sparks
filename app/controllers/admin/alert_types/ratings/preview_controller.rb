module Admin
  module AlertTypes
    module Ratings
      class PreviewController < AdminController
        load_and_authorize_resource :alert_type

        def show
          @alert = @alert_type.alerts.rating_between(from_parameter, to_parameter).order(created_at: :desc).first
          if @alert
            load_rating_requirements
            render template_path(params[:template]), layout: nil
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
          @content = TemplateInterpolation.new(content_version).interpolate(*AlertTypeRatingContentVersion.template_fields, with: @alert.template_variables)
          @chart = @alert.chart_variables_hash[content_version.chart_variable]
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
            content: AlertTypeRatingContentVersion.template_fields
          )
        end

        def template_path(key)
          case key
          when 'find_out_more' then 'schools/find_out_more/show'
          when 'email', 'sms' then key
          else 'no_template'
          end
        end
      end
    end
  end
end
