module Admin
  class ActivityTypesController < AdminController
    load_and_authorize_resource

    before_action :load_filters, only: [:new, :edit, :create, :update]
    before_action :load_chart_list, except: :index

    def index
      @activity_types = @activity_types.includes(:activity_category).order("activity_categories.name", :name)
    end

    def show
      @recorded = Activity.where(activity_type: @activity_type).count
      @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
    end

    def new
      add_activity_type_suggestions
    end

    def edit
      number_of_suggestions_so_far = @activity_type.activity_type_suggestions.count
      if number_of_suggestions_so_far > 8
        @activity_type.activity_type_suggestions.build
      else
        # Top up to 8
        add_activity_type_suggestions(number_of_suggestions_so_far)
      end
    end

    def create
      if @activity_type.save
        redirect_to admin_activity_types_path, notice: 'Activity type was successfully created.'
      else
        add_activity_type_suggestions
        render :new
      end
    end

    def update
      if @activity_type.update(activity_type_params)
        redirect_to admin_activity_types_path, notice: 'Activity type was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      # activity types should be marked inactive rather than deleted
      # this method does NOT delete the activity type
      # @activity_type.destroy
      redirect_to admin_activity_types_path, notice: 'Activity type not deleted, please mark as inactive'
    end

  private

    def add_activity_type_suggestions(number_of_suggestions_so_far = 0)
      (0..(7 - number_of_suggestions_so_far)).each { @activity_type.activity_type_suggestions.build }
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_type_params
      params.require(:activity_type).permit(:name,
          :description,
          :school_specific_description,
          :download_links,
          :image,
          :active,
          :activity_category_id,
          :score,
          :repeatable,
          :data_driven,
          key_stage_ids: [],
          impact_ids: [],
          subject_ids: [],
          topic_ids: [],
          activity_timing_ids: [],
          activity_type_suggestions_attributes: suggestions_params)
    end

    def suggestions_params
      [:id, :suggested_type_id, :_destroy]
    end

    def load_filters
      @key_stages = KeyStage.order(:name)
      @subjects = Subject.order(:name)
      @topics = Topic.order(:name)
      @impacts = Impact.order(:name)
      @activity_timings = ActivityTiming.order(:position)
    end

    def load_chart_list
      analysis_charts = DashboardConfiguration::DASHBOARD_PAGE_GROUPS.except(:simulator, :simulator_detail, :simulator_debug, :test, :pupil_analysis_page).map do |top_level_key, config|
        ["#{config[:name]} (#{top_level_key})", config.fetch(:charts) {[]}]
      end
      custom_activity_charts = [['Activity charts (custom)', ChartManager::STANDARD_CHART_CONFIGURATION.keys.grep(/^activities/)]]
      @chart_list = custom_activity_charts + analysis_charts
    end
  end
end
