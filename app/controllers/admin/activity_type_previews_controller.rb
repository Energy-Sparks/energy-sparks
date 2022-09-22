module Admin
  class ActivityTypePreviewsController < AdminController
    def create
      school = params['school_slug'] ? School.find(params['school_slug']) : School.process_data.order(:name).first
      activity_type = ActivityType.new(school_specific_description: school_specific_description(params))
      @activity_type_content = TemplateInterpolation.new(
        activity_type,
        render_with: SchoolTemplate.new(school)
      ).interpolate(
        :school_specific_description
      ).school_specific_description.body.to_html.html_safe
      render 'show', layout: nil
    end

    private

    def school_specific_description(params)
      description_attribute = 'school_specific_description'
      if (locale = params[:locale])
        description_attribute += "_#{locale}"
      end
      params[:activity_type][description_attribute]
    end
  end
end
