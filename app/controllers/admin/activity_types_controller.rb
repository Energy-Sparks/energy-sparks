module Admin
  class ActivityTypesController < AdminController
    load_and_authorize_resource

    before_action :load_filters, only: [:new, :edit, :create, :update]

    # GET /activity_types
    def index
      @activity_types = @activity_types.includes(:activity_category).order("activity_categories.name", :name)
    end

    # GET /activity_types/1
    def show
      @recorded = Activity.where(activity_type: @activity_type).count
      @school_count = Activity.select(:school_id).where(activity_type: @activity_type).distinct.count
    end

    # GET /activity_types/new
    def new
      add_activity_type_suggestions
    end

    # GET /activity_types/1/edit
    def edit
      number_of_suggestions_so_far = @activity_type.activity_type_suggestions.count
      if number_of_suggestions_so_far > 8
        @activity_type.activity_type_suggestions.build
      else
        # Top up to 8
        add_activity_type_suggestions(number_of_suggestions_so_far)
      end
    end

    # POST /activity_types
    def create
      if @activity_type.save
        redirect_to @activity_type, notice: 'Activity type was successfully created.'
      else
        add_activity_type_suggestions
        render :new
      end
    end

    # PATCH/PUT /activity_types/1
    def update
      if @activity_type.update(activity_type_params)
        redirect_to @activity_type, notice: 'Activity type was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /activity_types/1
    def destroy
      # activity types should be marked inactive rather than deleted
      # this method does NOT delete the activity type
      # @activity_type.destroy
      redirect_to activity_types_url, notice: 'Activity type not deleted, please mark as inactive'
    end

  private

    def add_activity_type_suggestions(number_of_suggestions_so_far = 0)
      (0..(7 - number_of_suggestions_so_far)).each { @activity_type.activity_type_suggestions.build }
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_type_params
      params.require(:activity_type).permit(:name,
          :description,
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
  end
end
