# frozen_string_literal: true

module Schools
  class UtilityStatusComponentPreview < ViewComponent::Preview
    # @param slug select :school_options
    def default(slug: nil)
      @slug = slug
      render(Schools::UtilityStatusComponent.new(school: school))
    end

    private

    def school
      @slug ? School.find(@slug) : schools.sample
    end

    def schools
      School.data_visible
    end

    def school_options
      {
        choices: schools.by_name.map { |g| [g.name, g.slug] }
      }
    end
  end
end
