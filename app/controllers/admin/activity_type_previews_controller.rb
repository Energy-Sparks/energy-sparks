module Admin
  class ActivityTypePreviewsController < AdminController
    def create
      school = School.active.first
      activity_type = ActivityType.new(school_specific_description: params[:activity_type][:school_specific_description])
      @content = TemplateInterpolation.new(
        activity_type,
        render_with: SchoolTemplate.new(school)
      ).interpolate(
        :school_specific_description
      )
      render 'show', layout: nil
    end
  end
end
