require 'rails_helper'


describe Alerts::System::ContentManaged do

  let(:school)  { create :school, name: 'St. Egberts' }

  let(:today){ Date.new(2019, 4, 26) }
  let(:report){ Alerts::System::ContentManaged.new(school: school, today: today).report }

  it 'has a rating of 5' do
    expect(report.rating).to eq(10.0)
  end

  it 'has a variable for the school name' do
    expect(report.template_data[:school_name]).to eq('St. Egberts')
  end

end

