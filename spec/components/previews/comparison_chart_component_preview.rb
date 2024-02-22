class ComparisonChartComponentPreview < ViewComponent::Preview
  def with_schools
    x_axis = School.all.sample(10).map(&:name)
    x_data = {
      'Demo': Array.new(10) { rand(1..10) }.sort.reverse
    }
    render(ComparisonChartComponent.new(id: :demo, x_axis: x_axis, x_data: x_data, y_axis_label: 'Demo Chart'))
  end
end
