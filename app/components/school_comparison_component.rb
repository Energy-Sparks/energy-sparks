class SchoolComparisonComponent < ViewComponent::Base
  include AdvicePageHelper

  renders_one :callout_footer

  def initialize(id: 'comparison', comparison:)
    @id = id
    @comparison = comparison
  end

  def render?
    @comparison.valid?
  end
end
