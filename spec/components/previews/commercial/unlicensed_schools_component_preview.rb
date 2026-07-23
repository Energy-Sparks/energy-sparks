# frozen_string_literal: true

module Commercial
  class UnlicensedSchoolsComponentPreview < ViewComponent::Preview
    def example
      schools = School.active.without_current_licence.joins(
        organisation_school_grouping: :school_group
      ).order('school_groups.name ASC')

      render Commercial::UnlicensedSchoolsComponent.new(schools:)
    end
  end
end
