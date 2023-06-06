# frozen_string_literal: true

class SchoolGroupComparisonComponent < ViewComponent::Base
  renders_one :callout_footer

  CATEGORIES = [:exemplar_school, :benchmark_school, :other_school].freeze

  def initialize(id:, comparison:)
    @id = id
    @comparison = comparison
  end

  def category
    @comparison.category.to_s
  end

  def categories
    CATEGORIES
  end

  def responsive_classes(category)
    if @comparison.category == category
      'd-flex'
    else
      'd-none d-md-block'
    end
  end
end
