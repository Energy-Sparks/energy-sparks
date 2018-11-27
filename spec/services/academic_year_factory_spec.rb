require 'rails_helper'

describe AcademicYearFactory, :academic_years, type: :service do
  it 'creates academic years inclusive' do
    service = AcademicYearFactory.new(2010, 2012)
    service.create
    expect(AcademicYear.count).to eq(3)
  end

  it 'validates input' do
    expect{ service = AcademicYearFactory.new(2018, 2012) }.to raise_error(ArgumentError)
  end
end