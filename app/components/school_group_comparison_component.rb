# frozen_string_literal: true

class SchoolGroupComparisonComponent < ViewComponent::Base
  renders_one :callout_footer

  CATEGORIES = [:exemplar_school, :benchmark_school, :other_school].freeze

  def initialize(id:, comparison:, advice_page_key:)
    @id = id
    @comparison = comparison
    @advice_page_key = advice_page_key
  end

  def advice_page_path_for(school_slug)
    send("school_advice_#{@advice_page_key}_path", school_id: school_slug)
  end
end
