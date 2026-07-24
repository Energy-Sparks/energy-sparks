# frozen_string_literal: true

module Commercial
  class LicensingSummaryComponentPreview < ViewComponent::Preview
    # @param slug select :group_options
    def example(slug: nil)
      school_group = slug ? SchoolGroup.find(slug) : SchoolGroup.with_active_schools.first
      academic_year = Calendar.default_national.current_academic_year

      render Commercial::LicensingSummaryComponent.new(
        date_range: academic_year.start_date..academic_year.end_date
      ) do |c|
        school_group.assigned_schools.each do |school|
          c.with_row school: school
        end
      end
    end

    private

    def group_options
      {
        choices: SchoolGroup.with_active_schools.by_name.map { |g| [g.name, g.slug] }
      }
    end
  end
end
