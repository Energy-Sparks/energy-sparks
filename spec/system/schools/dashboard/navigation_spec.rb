require 'rails_helper'

RSpec.shared_examples 'navigation' do
  before do
    visit school_path(test_school, switch: true)
  end

  it 'has link to pupil dashboard' do
    expect(page.has_link?('Pupil dashboard')).to be true
    within('.navbar-second') do
      click_on('Pupil dashboard')
    end
    expect(page.has_title?('Pupil dashboard')).to be true
  end

  context 'and school is not data-enabled' do
    before do
      test_school.update!(data_enabled: false)
      visit school_path(test_school, switch: true)
    end

    it 'does not show data-enabled links' do
      expect(html).not_to have_link(I18n.t('common.explore_energy_data'),
                                    href: school_advice_path(school))
    end
  end

  it 'has links to analysis' do
    expect(html).to have_link(I18n.t('common.explore_energy_data'),
                              href: school_advice_path(school))
  end

  context 'when school has partners' do
    let(:partner)             { create(:partner, name: 'School Sponsor', url: 'http://example.org') }
    let(:other_partner)       { create(:partner, name: 'Big Tech Co', url: 'https://example.com') }
    let(:school_group)        { create(:school_group, name: 'School Group')}

    before do
      test_school.update!({ school_group: school_group })
    end

    it 'displays school group partners' do
      test_school.school_group.partners << partner
      visit school_path(test_school, switch: true)
      expect(page).to have_link('School Sponsor', href: 'http://example.org')
    end

    it 'displays school partners' do
      test_school.partners << partner
      visit school_path(test_school, switch: true)
      expect(page).to have_link('School Sponsor', href: 'http://example.org')
    end

    it 'displays all partners' do
      test_school.school_group.partners << partner
      test_school.partners << other_partner
      visit school_path(test_school, switch: true)
      expect(page).to have_link('School Sponsor', href: 'http://example.org')
      expect(page).to have_link('Big Tech Co', href: 'https://example.com')
    end
  end
end

RSpec.describe 'adult dashboard navigation', type: :system do
  let(:school) { create(:school) }

  let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true)}

  before do
    # Update the configuration rather than creating one, as the school factory builds one
    # and so if we call create(:configuration, school: school) we end up with 2 records for a has_one
    # relationship
    school.configuration.update!(fuel_configuration: fuel_configuration)
    sign_in(user) if user.present?
  end

  context 'as guest' do
    let(:user) { nil }

    it_behaves_like 'navigation' do
      let(:test_school) { school }
    end

    it 'shows me the adult dashboard by default' do
      visit school_path(school)
      expect(page.has_link?('Pupil dashboard')).to be true
    end

    it 'shows login form' do
      visit school_path(school)
      expect(page).to have_content('Log in with your email address and password')
      expect(page).to have_content('Log in with your pupil password')
    end
  end

  context 'as pupil' do
    let(:user) { create(:pupil, school: school) }

    it_behaves_like 'navigation' do
      let(:test_school) { school }
    end

    it 'shows me the public dashboard by default' do
      visit schools_path
      expect(page.has_content?('Energy Sparks schools across the UK')).to be true
      click_on(school.name, match: :first)
      expect(page.has_link?('Adult dashboard')).to be true
    end
  end

  context 'as student' do
    let(:user) { create(:student, school: school) }

    it_behaves_like 'navigation' do
      let(:test_school) { school }
    end

    it 'shows me the public dashboard by default' do
      visit schools_path
      expect(page.has_content?('Energy Sparks schools across the UK')).to be true
      click_on(school.name, match: :first)
      expect(page.has_link?('Adult dashboard')).to be true
    end
  end

  context 'as staff' do
    let(:user) { create(:staff, school: school) }

    it_behaves_like 'navigation' do
      let(:test_school) { school }
    end

    it 'shows me the adult dashboard by default' do
      visit schools_path
      expect(page.has_content?('Energy Sparks schools across the UK')).to be true
      click_on(school.name, match: :first)
      expect(page.has_link?('Pupil dashboard')).to be true
    end

    it 'displays my school menu on other pages' do
      visit home_page_path
      expect(page).to have_css('#my-school-menu')
    end
  end

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }

    it_behaves_like 'navigation' do
      let(:test_school) { school }
    end

    it 'shows me the adult dashboard by default' do
      visit schools_path
      expect(page.has_content?('Energy Sparks schools across the UK')).to be true
      click_on(school.name, match: :first)
      expect(page.has_link?('Pupil dashboard')).to be true
    end

    it 'displays my school menu on other pages' do
      visit home_page_path
      expect(page).to have_css('#my-school-menu')
    end

    context 'with replacement advice pages' do
      it 'links to advice pages from review energy analysis' do
        visit school_path(school)
        click_on 'Explore energy data'
        expect(page).to have_content(I18n.t('advice_pages.index.title'))
      end

      it 'links to advice pages from my school menu' do
        visit school_path(school)
        within '#my-school-menu' do
          click_on 'Energy analysis'
        end
        expect(page).to have_content(I18n.t('advice_pages.index.title'))
      end
    end
  end

  context 'as group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, school_group: school_group) }
    let(:user)          { create(:group_admin, school_group: school_group) }

    it_behaves_like 'navigation' do
      let(:test_school) { school }
    end

    it 'shows me the adult dashboard by default' do
      visit schools_path
      expect(page.has_content?('Energy Sparks schools across the UK')).to be true
      click_on(school.name, match: :first)
      expect(page.has_link?('Pupil dashboard')).to be true
    end
  end
end
