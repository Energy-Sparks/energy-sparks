# frozen_string_literal: true

module Commercial
  class RangeFundingSummaryComponentPreview < ViewComponent::Preview
    # @param slug select :group_options
    def example(slug: nil)
      school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.first
      academic_year = Calendar.default_national.current_academic_year

      render Commercial::RangeFundingSummaryComponent.new(
        school_group:,
        range: academic_year.start_date..academic_year.end_date,
        range_label: 'this academic year'
      )
    end

    private

    def group_options
      {
        choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
      }
    end
  end
end
