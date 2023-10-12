require 'rails_helper'

describe "School Batch Reports", type: :system do
  let!(:school) { create(:school) }

  let!(:admin) { create(:admin) }

  before do
    sign_in(admin)
    visit school_reports_path(school)
  end

  describe 'equivalence reports' do
    let(:equivalence_type)          { create(:equivalence_type, time_period: :last_week)}
    let(:equivalence_type_content)  { create(:equivalence_type_content_version, equivalence_type: equivalence_type, equivalence: 'Your school spent {{gbp}} on electricity last year!')}
    let!(:equivalence)              { create(:equivalence, school: school, content_version: equivalence_type_content, data: { 'gbp' => { 'formatted_equivalence' => '£2.00' } }, data_cy: { 'welsh' => { 'today' => 'dydd Sadwrn' } }, to_date: Time.zone.today) }

    it 'has a link to equivalences report' do
      expect(page).to have_link(href: school_equivalence_reports_path(school))
    end

    context 'with report' do
      before(:each) do
        click_on 'Equivalences'
      end
      it 'shows equivalence' do
        expect(page).to have_content("1 equivalence generated")
        expect(page).to have_content(equivalence_type.meter_type.humanize)
        expect(page).to have_content(equivalence_type.time_period.humanize)
        click_on 'View'
        expect(page).to have_content("formatted_equivalence")
        expect(page).to have_content("dydd Sadwrn")
      end
    end
  end
end
