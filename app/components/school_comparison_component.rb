class SchoolComparisonComponent < ApplicationComponent
  renders_one :footer

  CATEGORIES = [:exemplar_school, :benchmark_school, :other_school].freeze

  def initialize(id: 'comparison', comparison:, **_kwargs)
    super
    @comparison = comparison
  end

  def category
    @comparison.category.to_s
  end

  def categories
    CATEGORIES
  end

  def school_in_category?(category)
    @comparison.category == category
  end

  def responsive_classes(category)
    if @comparison.category == category
      'd-flex'
    else
      'd-none d-md-block'
    end
  end

  def school_value
    format_unit(@comparison.school_value).html_safe
  end

  def exemplar_value
    format_unit(@comparison.exemplar_value).html_safe
  end

  def benchmark_value
    return nil unless @comparison.benchmark_value
    format_unit(@comparison.benchmark_value).html_safe
  end

  def other_value
    return exemplar_value unless @comparison.benchmark_value
    format_unit(@comparison.benchmark_value).html_safe
  end

  def format_unit(value)
    FormatEnergyUnit.format(@comparison.unit, value, :text)
  end

  def render?
    @comparison.valid?
  end

  def exemplar_value_sign
    (@comparison.low_is_good ? '&lt;' : '&gt;').html_safe
  end

  def benchmark_value_sign
    (@comparison.low_is_good ? '&lt;' : '&gt;').html_safe
  end

  def other_value_sign
    (@comparison.low_is_good ? '&gt;' : '&lt;').html_safe
  end
end
