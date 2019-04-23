module Schools
  class FindOutMoreController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource

    skip_before_action :authenticate_user!

    def show
      @activity_types = ActivityTypeFilter.new(school: @school, scope: @find_out_more.activity_types).activity_types.limit(3)
      @alert = @find_out_more.alert
      @content = TemplateInterpolation.new(@find_out_more.content_version).interpolate(:page_title, :page_content, with: @alert.template_variables)
      @charts = @alert.charts
      @tables = @alert.tables
    end
  end
end
