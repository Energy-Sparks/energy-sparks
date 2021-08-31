module Schools
  class ActivityTypesController < ::ActivityTypesController
    load_resource :school
    load_and_authorize_resource

    before_action :load_content, only: :show

    def load_content
      @content = TemplateInterpolation.new(
        @activity_type,
        render_with: SchoolTemplate.new(@school)
      ).interpolate(
        :school_specific_description_or_fallback
      )
    end
  end
end
