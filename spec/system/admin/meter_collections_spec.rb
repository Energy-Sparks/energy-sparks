require 'rails_helper'

describe "meter collections", type: :system do

  let(:school_name)   { 'Oldfield Park Infants'}
  let!(:school)       { create(:school,:with_school_group, name: school_name)}
  let!(:admin)        { create(:admin)}

  before(:each) do
    sign_in(admin)
    visit root_path
    click_on('Reports')
    click_on('Download meter collections')
    expect(page.has_content?(school.name)).to be true
  end

  context 'when a meter has unvalidated readings' do
    let!(:meter)        { create(:electricity_meter_with_reading, name: 'Electricity meter', school: school) }

    it 'allows a download of unvalidated meter collection' do
      click_on 'Unvalidated meter collection'

      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /unvalidated-meter-collection-#{school.name.parameterize}.yaml$/
    end
  end

  context 'when a meter has validated readings' do
    let!(:meter)        { create(:electricity_meter_with_validated_reading, name: 'Electricity meter', school: school) }

    it 'allows a download of validated meter collection' do
      click_on 'Validated meter collection'

      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /validated-meter-collection-#{school.name.parameterize}.yaml$/
    end
  end

  context 'when a school has no meters' do

    it 'can download an aggregated meter collection - no meters to aggregate' do
      allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(school)

      click_on 'Aggregated meter collection'

      header = page.response_headers['Content-Disposition']
      expect(header).to match /^attachment/
      expect(header).to match /aggregated-meter-collection-#{school.name.parameterize}.yaml$/

    end
  end
end
