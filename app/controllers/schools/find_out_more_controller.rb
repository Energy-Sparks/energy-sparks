module Schools
  class FindOutMoreController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource

    skip_before_action :authenticate_user!

    def show
      activity_type_filter = ActivityTypeFilter.new(school: @school, scope: @find_out_more.activity_types, query: { not_completed_or_repeatable: true })
      @activity_types = activity_type_filter.activity_types.limit(3)
      @alert = @find_out_more.alert
      @content = TemplateInterpolation.new(@find_out_more.content_version).interpolate(:page_title, :page_content, with: @alert.template_variables)
      @charts = @alert.charts
      @tables = @alert.tables
    end
  end
end
