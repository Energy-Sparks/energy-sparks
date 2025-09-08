class SchoolComparisonComponentPreview < ViewComponent::Preview
  def exemplar
    comparison = Schools::Comparison.new(
      school_value: 9,
      benchmark_value: 20,
      exemplar_value: 10,
      unit: :kw
    )

    render SchoolComparisonComponent.new(id: 'my-id', comparison: comparison) do |c|
      c.with_footer { 'footer' }
    end
  end

  def well_managed
    comparison = Schools::Comparison.new(
      school_value: 15,
      benchmark_value: 20,
      exemplar_value: 10,
      unit: :kw
    )

    render SchoolComparisonComponent.new(id: 'my-id', comparison: comparison) do |c|
      c.with_footer { 'footer' }
    end
  end

  def action_needed
    comparison = Schools::Comparison.new(
      school_value: 21,
      benchmark_value: 20,
      exemplar_value: 10,
      unit: :kw
    )

    render SchoolComparisonComponent.new(id: 'my-id', comparison: comparison) do |c|
      c.with_footer { 'footer' }
    end
  end
end
