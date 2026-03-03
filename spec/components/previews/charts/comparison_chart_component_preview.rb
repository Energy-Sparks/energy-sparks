class Charts::ComparisonChartComponentPreview < ViewComponent::Preview
  # @param schools "Number of random schools to display"
  # @param series_name "Name of series" select { choices: ['Demo', 'Electricity', 'Gas', 'School Day Open', 'Holiday'] }
  # @param fuel_type "Used as fallback colour choice" select { choices: ['', electricity, gas, solar_pv, storage_heaters] }
  # @param y_axis_label "Y Axis Label"
  def with_schools(schools: 10, series_name: 'Demo', fuel_type: nil, y_axis_label: 'Demo Chart')
    x_axis = School.all.sample(schools).map(&:name)
    x_data = {
      series_name => Array.new(schools) { rand(1..10) }.sort.reverse
    }
    fuel_type = fuel_type.present? ? fuel_type.to_sym : nil
    render(Charts::ComparisonChartComponent.new(id: :demo, x_axis: x_axis, x_data: x_data, y_axis_label:, fuel_type:))
  end
end
