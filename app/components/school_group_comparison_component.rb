# frozen_string_literal: true

class SchoolGroupComparisonComponent < ViewComponent::Base
  renders_one :callout_footer

  CATEGORIES = [:exemplar_school, :benchmark_school, :other_school].freeze

  def initialize(id:, school_group:)
    @id = id
    @school_group = school_group
    @comparison = categorise_schools
  end

  private

  def categorise_schools
    # Todo this will call out to a service to categorise the schools
    OpenStruct.new(
      exemplar_school: [@school_group.schools[0]],
      benchmark_school: @school_group.schools[1..3],
      other_school: @school_group.schools[4..7]
    )
  end
end
