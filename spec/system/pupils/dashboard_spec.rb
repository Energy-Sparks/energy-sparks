require 'rails_helper'

describe 'Pupil dashboard' do
  let(:school_name)         { 'Theresa Green Infants'}
  let!(:school_group)       { create(:school_group) }
  let!(:regional_calendar)  { create(:regional_calendar) }
  let!(:calendar)           { create(:school_calendar, based_on: regional_calendar) }
  let!(:school)             { create(:school, :with_feed_areas, calendar: calendar, name: school_name, school_group: school_group) }
  let!(:intervention)       { create(:observation, :temperature, school: school) }

  let(:equivalence_type)          { create(:equivalence_type, time_period: :last_week)}
  let(:equivalence_type_content)  { create(:equivalence_type_content_version, equivalence_type: equivalence_type, equivalence_en: 'Your school spent {{gbp}} on electricity last year!', equivalence_cy: 'Gwariodd eich ysgol {{gbp}} ar drydan y llynedd!')}
  let!(:equivalence)              { create(:equivalence, school: school, content_version: equivalence_type_content, data: { 'gbp' => { 'formatted_equivalence' => '£2.00' } }, data_cy: { 'gbp' => { 'formatted_equivalence' => '£9.00' } }, to_date: Time.zone.today) }

  let(:pupil) { create(:pupil, school: school)}

  shared_examples 'a pupil dashboard viewed when logged out' do
    before do
      visit pupils_school_path(school)
    end

    it 'shows login form' do
      expect(page).to have_content('Log in with your email address and password')
      expect(page).to have_content('Log in with your pupil password')
    end

    context 'for school with non-public data' do
      before do
        school.update!(data_sharing: :within_group)
      end

      it 'prompts for login' do
        visit pupils_school_path(school)
        expect(page.has_content?('This school has disabled public access')).to be true
      end
    end
  end

  shared_examples 'a data enabled pupil dashboard' do
    before do
      visit pupils_school_path(school)
    end

    it 'shows equivalences' do
      expect(page).to have_content('Your school spent £2.00 on electricity last year!')
    end

    it 'shows Welsh equivalences' do
      visit pupils_school_path(school, locale: 'cy')
      expect(page).to have_content('Gwariodd eich ysgol £9.00 ar drydan y llynedd')
    end

    context 'with observations' do
      let(:activity_type) { create(:activity_type) }
      let(:intervention_type) { create(:intervention_type, name: 'Upgraded insulation') }

      before do
        create(:observation, :intervention, school: school, intervention_type: intervention_type)
        create(:activity, school: school, activity_type: activity_type)
        visit pupils_school_path(school)
      end

      it 'displays activity and actions in a timeline' do
        expect(page).to have_content(intervention_type.name)
        expect(page).to have_content(activity_type.name)
        expect(page).to have_link(href: school_timeline_path(school))
        visit school_timeline_path(school)
        expect(page).to have_content(intervention_type.name)
        expect(page).to have_content(activity_type.name)
      end
    end

    it 'hides old equivalences' do
      expect(equivalence.content_version.equivalence_type.time_period).to eq 'last_week'
      equivalence.update!(to_date: 50.days.ago)
      visit pupils_school_path(school)
      expect(page).to have_content(school_name)
      expect(page).not_to have_content('Your school spent £2.00 on electricity last year!')
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

  shared_examples 'a non-data enabled pupil dashboard' do
    before do
      school.update!(data_enabled: false)
      visit pupils_school_path(school)
    end

    it 'doesnt show generated equivalences' do
      expect(page).not_to have_content('Your school spent £2.00 on electricity last year!')
    end

    it 'shows default equivalences' do
      expect(page).to have_content('the average school')
      expect(page).to have_content('How will your school compare?')
    end
  end

  context 'when viewing as guest user' do
    it_behaves_like 'a pupil dashboard viewed when logged out'
    it_behaves_like 'a data enabled pupil dashboard'

    context 'when school is not data-enabled' do
      it_behaves_like 'a non-data enabled pupil dashboard'
    end
  end

  context 'when logged in as pupil' do
    before do
      sign_in(pupil)
      visit pupils_school_path(school)
    end

    it 'has navigation to adult dashboard' do
      expect(page).to have_content(school.name.to_s)
      expect(page).to have_link('Adult dashboard', href: school_path(school, switch: true))
      click_on 'Adult dashboard'
      expect(page).to have_title('Adult dashboard')
      click_on 'Pupil dashboard'
      expect(page).to have_title('Pupil dashboard')
    end

    it 'redirects to pupil dashboard' do
      visit root_path
      expect(page).to have_content(school.name.to_s)
      expect(page).to have_title('Pupil dashboard')
    end

    it_behaves_like 'a data enabled pupil dashboard'

    context 'when school is not data-enabled' do
      it_behaves_like 'a non-data enabled pupil dashboard'
    end
  end

  context 'with new dashboard enabled' do
    context 'when viewing as guest user' do
      it_behaves_like 'a pupil dashboard viewed when logged out'
      it_behaves_like 'a data enabled pupil dashboard'

      context 'when school is not data-enabled' do
        it_behaves_like 'a non-data enabled pupil dashboard'
      end
    end

    context 'when logged in as pupil' do
      before do
        sign_in(pupil)
        visit pupils_school_path(school)
      end

      it 'has navigation to adult dashboard' do
        expect(page).to have_content(school.name.to_s)
        expect(page).to have_link('Adult dashboard', href: school_path(school, switch: true))
        click_on 'Adult dashboard'
        expect(page).to have_title('Adult dashboard')
        click_on 'Pupil dashboard'
        expect(page).to have_title('Pupil dashboard')
      end

      it 'redirects to pupil dashboard' do
        visit root_path
        expect(page).to have_content(school.name.to_s)
        expect(page).to have_title('Pupil dashboard')
      end

      it_behaves_like 'a data enabled pupil dashboard'

      context 'when school is not data-enabled' do
        it_behaves_like 'a non-data enabled pupil dashboard'
      end
    end
  end
end
