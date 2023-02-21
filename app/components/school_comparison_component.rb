class SchoolComparisonComponent < ViewComponent::Base
  renders_one :callout_footer

  def initialize(id: 'comparison', comparison:)
    @id = id
    @comparison = comparison
  end

  def category
    @comparison.category.to_s
  end

  def categories
    [:exemplar_school, :benchmark_school, :other_school]
  end

  def school_in_category?(category)
    @comparison.category == category
  end

  def responsive_classes(category)
    if @comparison.category == category
      'd-flex'
    else
      ' d-none d-md-block'
    end
  end

  def school_value
    format_unit(@comparison.school_value).html_safe
  end

  def exemplar_value
    format_unit(@comparison.exemplar_value).html_safe
  end

  def benchmark_value
    format_unit(@comparison.benchmark_value).html_safe
  end

  def format_unit(value)
    FormatEnergyUnit.format(@comparison.unit, value, :text)
  end

  def render?
    @comparison.valid?
  end
end
