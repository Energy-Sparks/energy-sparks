module Pupils
  class SchoolsController < ApplicationController
    include ActionView::Helpers::NumberHelper
    include SchoolAggregation
    include DashboardAlerts
    include DashboardTimeline
    include NonPublicSchools
    include SchoolProgress

    load_resource

    skip_before_action :authenticate_user!

    before_action only: [:show] do
      redirect_unless_permitted :show
    end
    before_action :set_breadcrumbs

    def show
      authorize! :show_pupils_dash, @school
      @audience = :pupil
      @observations = setup_timeline(@school.observations)
      @progress_summary = progress_service.progress_summary if @school.data_enabled?
      render :show, layout: 'dashboards'
    end

  private

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('dashboards.pupil_dashboard') }]
    end
  end
end
