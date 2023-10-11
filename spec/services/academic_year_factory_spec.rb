require 'rails_helper'

describe AcademicYearFactory, :academic_years, type: :service do
  let(:calendar) { create(:calendar) }

  it 'creates academic years inclusive' do
    service = AcademicYearFactory.new(calendar)
    service.create(start_year: 2010, end_year: 2012)
    expect(AcademicYear.count).to eq(3)
  end

  it 'validates input' do
    expect { service = AcademicYearFactory.new(calendar).create(start_year: 2018, end_year: 2012) }.to raise_error(ArgumentError)
  end

  it 'allows setting of start and end month' do
    service = AcademicYearFactory.new(calendar, start_date: '01-08', end_date: '31-07').create(start_year: 2012, end_year: 2012)
    expect(AcademicYear.first.start_date.month).to eq(8)
  end
end
