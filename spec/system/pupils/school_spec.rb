require 'rails_helper'

RSpec.describe "pupils school view", type: :system do

  let(:school_name)               { 'Theresa Green Infants'}
  let!(:school)                   { create(:school, name: school_name)}
  let!(:user)                     { create(:pupil, school: school)}

  let(:equivalence_type)          { create(:equivalence_type, time_period: :last_week )}
  let(:equivalence_type_content)  { create(:equivalence_type_content_version, equivalence_type: equivalence_type, equivalence: 'Your school spent {{gbp}} on electricity last year!')}
  let!(:equivalence)              { create(:equivalence, school: school, content_version: equivalence_type_content, data: {'gbp' => {'formatted_equivalence' => '£2.00'}}, to_date: Date.today ) }

  describe 'when not logged in' do
    it 'displays pupil dashboard for visible schools' do
      visit pupils_school_path(school)
      expect(page).to have_content('Your school spent £2.00 on electricity last year!')
    end

    context 'for non-public school' do
      before(:each) do
        school.update!(public: false)
      end

      it 'prompts for login' do
        visit pupils_school_path(school)
        expect(page.has_content? 'This school has disabled public access to its data').to be true
      end
    end
  end

  describe 'when logged in as pupil' do
    before(:each) do
      sign_in(user)
    end

    it 'I can visit the pupil dashboard' do
      visit pupils_school_path(school)
      expect(page).to have_content(school_name)
      expect(page).to have_content('Your school spent £2.00 on electricity last year!')
    end

    it 'hides old equivalences' do
      expect(equivalence.content_version.equivalence_type.time_period).to eq 'last_week'
      equivalence.update!(to_date: 50.days.ago)
      visit pupils_school_path(school)
      expect(page).to have_content(school_name)
      expect(page).to_not have_content('Your school spent £2.00 on electricity last year!')
    end

    it "hides old equivalences unless it's an old academic year one" do
      expect(equivalence.content_version.equivalence_type.time_period).to eq 'last_week'
      equivalence.update!(to_date: 50.days.ago)
      equivalence_type.update!(time_period: :last_academic_year)
      visit pupils_school_path(school)
      expect(page).to have_content(school_name)
      expect(page).to have_content('Your school spent £2.00 on electricity last year!')
    end
  end
end
