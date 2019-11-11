module Schools
  class AnnotationsController < ApplicationController
    skip_before_action :authenticate_user!

    def show
      @school = School.visible.find(params[:school_id])
      annotator = Charts::Annotate.new(interventions_scope: @school.observations.intervention)
      @annotations = case params[:date_grouping]
                     when 'weekly' then annotator.annotate_weekly(params[:x_axis_categories])
                     when 'daily' then annotator.annotate_daily(params[:x_axis_start], params[:x_axis_end])
                     else []
                     end
    end
  end
end
