class Charts::ComparisonChartComponentPreview < ViewComponent::Preview
  # @param schools Number of random schools to display
  def with_schools(schools: 10)
    x_axis = School.all.sample(schools).map(&:name)
    x_data = {
      'Demo': Array.new(schools) { rand(1..10) }.sort.reverse
    }
    render(Charts::ComparisonChartComponent.new(id: :demo, x_axis: x_axis, x_data: x_data, y_axis_label: 'Demo Chart'))
  end
end
