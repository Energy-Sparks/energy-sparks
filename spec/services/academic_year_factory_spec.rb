require 'rails_helper'

describe AcademicYearFactory, :academic_years, type: :service do

  let(:calendar_area){ create(:calendar_area) }

  it 'creates academic years inclusive' do
    service = AcademicYearFactory.new(calendar_area)
    service.create(start_year: 2010, end_year: 2012)
    expect(AcademicYear.count).to eq(3)
  end

  it 'validates input' do
    expect{ service = AcademicYearFactory.new(calendar_area).create(start_year: 2018, end_year: 2012) }.to raise_error(ArgumentError)
  end
end
