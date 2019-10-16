
require 'rails_helper'

describe SchoolTemplate do

  it 'allows a chart to be rendered with an attribute' do
    school = double :school, to_param: 'school-slug'

    template = SchoolTemplate.new(school)
    rendered = template.render("{{#chart}}daily_electricity_breakdown{{/chart}}", {})
    expect(rendered).to include('id="chart_daily_electricity_breakdown"')
  end

  it 'can specify a y-axis-unit with a bar' do
    school = double :school, to_param: 'school-slug'

    template = SchoolTemplate.new(school)
    rendered = template.render("{{#chart}}daily_electricity_breakdown|kwh{{/chart}}", {})
    expect(rendered).to include('kwh')
  end

end
