module Schools
  class FindOutMoreController < ApplicationController
    include AdvicePageHelper

    load_and_authorize_resource :school
    load_and_authorize_resource

    skip_before_action :authenticate_user!
    before_action :redirect_if_disabled_and_not_admin

    def show
      activity_type_filter = ActivityTypeFilter.new(school: @school, scope: @find_out_more.activity_types, query: { exclude_if_done_this_year: true })
      @activity_types = activity_type_filter.activity_types.limit(3)
      @actions = @find_out_more.intervention_types.limit(3)
      @alert = @find_out_more.alert
      @content_managed = content_managed?
      @content = TemplateInterpolation.new(@find_out_more.content_version).interpolate(:find_out_more_title, :find_out_more_content, :find_out_more_chart_title, with: @alert.template_variables)
      @chart = @alert.chart_data[@find_out_more.content_version.find_out_more_chart_variable]
      @table = @alert.table_data[@find_out_more.content_version.find_out_more_table_variable]
    end

    private

    def content_managed?
      @find_out_more.alert.alert_type.class_name == "Alerts::System::ContentManaged"
    end

    def redirect_if_disabled_and_not_admin
      return unless EnergySparks::FeatureFlags.active?(:replace_find_out_mores)
      return if current_user.present? && current_user.admin?
      if @find_out_more.alert_type.advice_page.present?
        redirect_to advice_page_path(@school, @find_out_more.alert_type.advice_page)
      else
        redirect_to school_advice_path(@school)
      end
    end
  end
end
