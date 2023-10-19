require 'rails_helper'

RSpec.describe "chart view", type: :system do
  let(:school_name) { 'Theresa Green Infants' }
  let(:school)      { create(:school, name: school_name) }

  it 'I can visit a school chart page' do
    allow_any_instance_of(SchoolAggregation).to receive(:aggregate_school).with(school).and_return(school)
    visit school_chart_path(school, chart_type: :daytype_breakdown_electricity)
    expect(page.has_content?(school_name)).to be true
    expect(page.has_content?('Daytype breakdown electricity'))
  end
end
