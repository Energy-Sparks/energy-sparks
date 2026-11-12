# frozen_string_literal: true

module Admin
  class ActivityTypesController < Activities::BaseController
    include LocaleHelper

    load_and_authorize_resource
    before_action :load_filters, only: %i[new edit create update]
    before_action :load_chart_list, except: :index
    before_action :add_breadcrumbs

    def index
      @activity_types = @activity_types.includes(:activity_category).order('activity_categories.name', :name)
    end

    def show
      @recorded = Activity.where(activity_type: @activity_type).count
      @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
    end

    def new
      add_activity_type_suggestions
      3.times do
        @activity_type.link_rewrites.build
      end
    end

    def edit
      number_of_suggestions_so_far = @activity_type.activity_type_suggestions.count
      if number_of_suggestions_so_far > 8
        @activity_type.activity_type_suggestions.build
      else
        # Top up to 8
        add_activity_type_suggestions(number_of_suggestions_so_far)
      end
      3.times do
        @activity_type.link_rewrites.build
      end
    end

    def create
      if @activity_type.save
        redirect_to admin_activity_types_path, notice: 'Activity was successfully created.'
      else
        add_activity_type_suggestions
        render :new
      end
    end

    def update
      if @activity_type.update(activity_type_params)
        # Rewrite links in Welsh text
        rewritten = @activity_type.update(@activity_type.rewrite_all)
        notice = if rewritten
                   'Activity was successfully updated.'
                 else
                   'Activity was saved, but failed to rewrite links.'
                 end
        redirect_to admin_activity_types_path, notice: notice
      else
        render :edit
      end
    end

    def destroy
      # activity types should be marked inactive rather than deleted
      # this method does NOT delete the activity type
      # @activity_type.destroy
      redirect_to admin_activity_types_path, notice: 'Activity not deleted, please mark as inactive'
    end

    private

    def add_activity_type_suggestions(number_of_suggestions_so_far = 0)
      (0..(7 - number_of_suggestions_so_far)).each { @activity_type.activity_type_suggestions.build }
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_type_params
      translated = t_params(ActivityType.mobility_attributes + ActivityType.t_attached_attributes)
      scalars = %i[name description summary school_specific_description download_links active
                   activity_category_id score maximum_frequency data_driven show_on_charts]
      params.expect(activity_type: [*translated, *scalars,
                                    { key_stage_ids: [], impact_ids: [], subject_ids: [],
                                      activity_timing_ids: [], fuel_type: [],
                                      link_rewrites_attributes: [link_rewrites_params],
                                      activity_type_suggestions_attributes: [suggestions_params] }])
    end

    def suggestions_params
      %i[id suggested_type_id _destroy]
    end

    def link_rewrites_params
      %i[id source target _destroy]
    end

    def load_filters
      @key_stages = KeyStage.order(:name)
      @subjects = Subject.order(:name)
      @impacts = Impact.order(:name)
      @activity_timings = ActivityTiming.order(:position)
    end

    def load_chart_list
      excluded_groups = %i[simulator simulator_detail simulator_debug test pupil_analysis_page
                           heating_model_fitting cost_unused]
      analysis_charts = DashboardConfiguration::DASHBOARD_PAGE_GROUPS
                        .except(*excluded_groups)
                        .map do |top_level_key, config|
        ["#{config[:name]} (#{top_level_key})", config.fetch(:charts) { [] }]
      end
      custom_activity_charts = [['Activity charts (custom)', ChartManager::STANDARD_CHART_CONFIGURATION.keys.grep(/^activities/)]]
      @chart_list = custom_activity_charts + analysis_charts
    end

    def add_breadcrumbs
      @breadcrumbs << { name: 'Activities', href: admin_activity_types_path }
    end
  end
end
