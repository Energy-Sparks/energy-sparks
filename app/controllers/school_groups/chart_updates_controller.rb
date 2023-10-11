module SchoolGroups
  class ChartUpdatesController < ApplicationController
    before_action :header_fix_enabled
    load_and_authorize_resource :school_group

    def index
      redirect_to school_group_path(@school_group) and return unless can?(:update_settings, @school_group)

      @breadcrumbs = [
        { name: I18n.t('common.schools'), href: schools_path },
        { name: @school_group.name, href: school_group_path(@school_group) },
        { name: t('school_groups.chart_updates.index.group_chart_settings').capitalize }
      ]
    end

    def bulk_update_charts
      redirect_to school_group_path(@school_group) and return unless can?(:update_settings, @school_group)

      if @school_group.schools.update_all(chart_preference: default_chart_preference) && @school_group.update!(default_chart_preference: default_chart_preference)
        count = @school_group.schools.count
        notice = t('school_groups.chart_updates.bulk_update_charts.notice', school_group_name: @school_group.name, count: count)
        redirect_to(school_group_chart_updates_path(@school_group), notice: notice) and return
      else
        render :index, status: :unprocessable_entity
      end
    end

    private

    def default_chart_preference
      default_chart_preference_update_params['default_chart_preference']
    end

    def default_chart_preference_update_params
      params.require(:school_group).permit(:default_chart_preference)
    end
  end
end
