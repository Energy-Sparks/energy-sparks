# frozen_string_literal: true

class SchoolGroupComparisonComponent < ViewComponent::Base
  renders_one :callout_footer

  CATEGORIES = [:exemplar_school, :benchmark_school, :other_school].freeze

  def initialize(id:, school_group:)
    @id = id
    # @school_group = school_group
    @comparison = school_group.categorise_schools
  end
end
