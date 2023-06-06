# frozen_string_literal: true

class SchoolGroupComparisonComponent < ViewComponent::Base
  renders_one :callout_footer

  CATEGORIES = [:exemplar_school, :benchmark_school, :other_school].freeze

  def initialize(id:, comparison:)
    @id = id
    @comparison = comparison
  end
end
