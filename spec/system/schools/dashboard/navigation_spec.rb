require 'rails_helper'

RSpec.shared_examples "navigation" do
  before(:each) do
    visit school_path(test_school, switch: true)
  end

  it 'has link to pupil dashboard' do
    expect(page.has_link? "Pupil dashboard").to be true
    within('.sub-navbar') do
      click_on('Pupil dashboard')
    end
    expect(page.has_title? 'Pupil dashboard').to be true
  end

  context 'and school is not data-enabled' do
    before(:each) do
      test_school.update!(data_enabled: false)
      visit school_path(test_school, switch: true)
    end
    it 'does not show data-enabled links' do
      within('.application') do
        expect(page).to_not have_link("Compare schools")
        expect(page).to_not have_link("Explore data")
        expect(page).to_not have_link("Review energy analysis")
        expect(page).to_not have_link("Print view")
      end
    end
  end

  it 'has links to analysis' do
    expect(page).to have_link("Explore data")
    expect(page).to have_link("Review energy analysis")
  end

  context 'with co2 analysis' do
    before(:each) do
      co2_page = double(analysis_title: 'Some CO2 page', analysis_page: 'analysis/page/co2')
      expect_any_instance_of(SchoolsController).to receive(:process_analysis_templates).and_return([co2_page])
      visit school_path(test_school, switch: true)
    end
    it 'shows link to co2 analysis page' do
      expect(page).to have_link("Some CO2 page")
    end
  end

  context 'when school has partners' do

    let(:partner)             { create(:partner, name: "School Sponsor", url: "http://example.org") }
    let(:other_partner)       { create(:partner, name: "Big Tech Co", url: "https://example.com") }
    let(:school_group)        { create(:school_group, name: 'School Group')}

    before(:each) do
      test_school.update!( { school_group: school_group })
    end

    it 'displays school group partners' do
      test_school.school_group.partners << partner
      visit school_path(test_school, switch: true)
      expect(page).to have_link("School Sponsor", href: "http://example.org")
    end

    it 'displays school partners' do
      test_school.partners << partner
      visit school_path(test_school, switch: true)
      expect(page).to have_link("School Sponsor", href: "http://example.org")
    end

    it 'displays all partners' do
      test_school.school_group.partners << partner
      test_school.partners << other_partner
      visit school_path(test_school, switch: true)
      expect(page).to have_link("School Sponsor", href: "http://example.org")
      expect(page).to have_link("Big Tech Co", href: "https://example.com")
    end

  end

  context 'when school in public group' do
    before(:each) do
      test_school.update(school_group: create(:school_group))
    end

    it 'links to compare schools' do
      visit school_path(test_school, switch: true)
      within('.application') do
        expect(page).to have_link("Compare schools")
      end
    end
  end
end

RSpec.describe "adult dashboard navigation", type: :system do
  let(:school_name)         { 'Oldfield Park Infants' }
  let(:school)             { create(:school, name: school_name) }

  let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true)}

  before(:each) do
    #Update the configuration rather than creating one, as the school factory builds one
    #and so if we call create(:configuration, school: school) we end up with 2 records for a has_one
    #relationship
    school.configuration.update!(fuel_configuration: fuel_configuration)
    sign_in(user) if user.present?
  end

  context 'as guest' do
    let(:user)                { nil }
    include_examples "navigation" do
      let(:test_school) { school }
    end

    it 'shows me the adult dashboard by default' do
      visit root_path
      click_on('View schools')
      expect(page.has_content? "Energy Sparks schools across the UK").to be true
      click_on(school_name)
      expect(page.has_link? "Pupil dashboard").to be true
    end

    it 'shows login form' do
      visit school_path(school)
      expect(page).to have_content('Log in with your email address and password')
      expect(page).to have_content('Log in with your pupil password')
    end

    context 'when school in private group' do
      before(:each) do
        school.update(school_group: create(:school_group, public: false))
      end

      it 'does not link to compare schools' do
        visit school_path(school, switch: true)
        within('.application') do
          expect(page).to_not have_link("Compare schools")
        end
      end
    end

  end

  context 'as pupil' do
    let(:user)          { create(:pupil, school: school) }
    include_examples "navigation" do
      let(:test_school) { school }
    end

    it 'shows me the public dashboard by default' do
      visit schools_path
      expect(page.has_content? "Energy Sparks schools across the UK").to be true
      click_on(school_name, match: :first)
      expect(page.has_link? "Adult dashboard").to be true
    end

    it 'displays a printable version of the dashboard' do
      visit school_path(school, switch: true)
      click_on 'Print view'
      expect(page).to have_content("Adult dashboard for #{school.name}")
    end

    context 'when school in private group' do
      before(:each) do
        school.update(school_group: create(:school_group, public: false))
      end

      it 'links to compare schools' do
        visit school_path(school, switch: true)
        within('.application') do
          expect(page).to have_link("Compare schools")
        end
      end
    end
  end

  context 'as staff' do
    let(:user)   { create(:staff, school: school) }

    include_examples "navigation" do
      let(:test_school) { school }
    end

    it 'shows me the adult dashboard by default' do
      visit schools_path
      expect(page.has_content? "Energy Sparks schools across the UK").to be true
      click_on(school_name, match: :first)
      expect(page.has_link? "Pupil dashboard").to be true
    end

    it 'should have my school menu' do
      visit school_path(school)
      expect(page).to have_css("#my_school_menu")
      expect(page).to have_link("Electricity usage")
      expect(page).to have_link("Gas usage")
      expect(page).to have_link("Storage heater usage")
      expect(page).to have_link("Energy analysis")
      expect(page).to have_link("My alerts")
      expect(page).to have_link("School programmes")
      expect(page).to have_link("Complete pupil activities")
      expect(page).to have_link("Energy saving actions")
      expect(page).to have_link("Download our data")
    end

    it 'should display my school menu on other pages' do
      visit home_page_path
      expect(page).to have_css("#my_school_menu")
    end

    it 'displays a printable report version of the page' do
      visit school_path(school)
      click_on 'Print view'
      expect(page).to have_content("Adult dashboard for #{school.name}")
    end

    context 'and school is not data-enabled' do
      before(:each) do
        school.update!(data_enabled: false)
        visit school_path(school)
      end
      it 'should not have data enabled features in my school menu' do
        expect(page).to have_css("#my_school_menu")
        expect(page).to_not have_link("Electricity usage")
        expect(page).to_not have_link("Gas usage")
        expect(page).to_not have_link("Storage heater usage")
        expect(page).to_not have_link("Energy analysis")
        expect(page).to have_link("My alerts")
        expect(page).to have_link("School programmes")
        expect(page).to have_link("Complete pupil activities")
        expect(page).to have_link("Energy saving actions")
        expect(page).to_not have_link("Download our data")
        expect(page).to_not have_link("Review targets")
      end
    end

    context 'when school in private group' do
      before(:each) do
        school.update(school_group: create(:school_group, public: false))
      end

      it 'links to compare schools' do
        visit school_path(school, switch: true)
        within('.application') do
          expect(page).to have_link("Compare schools")
        end
      end
    end

  end

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }
    include_examples "navigation" do
      let(:test_school) { school }
    end

    it 'shows me the adult dashboard by default' do
      visit schools_path
      expect(page.has_content? "Energy Sparks schools across the UK").to be true
      click_on(school_name, match: :first)
      expect(page.has_link? "Pupil dashboard").to be true
    end

    it 'should have my school menu' do
      visit school_path(school)
      expect(page).to have_css("#my_school_menu")
      expect(page).to have_link("Electricity usage")
      expect(page).to have_link("Gas usage")
      expect(page).to have_link("Storage heater usage")
      expect(page).to have_link("Energy analysis")
      expect(page).to have_link("My alerts")
      expect(page).to have_link("School programmes")
      expect(page).to have_link("Complete pupil activities")
      expect(page).to have_link("Energy saving actions")
      expect(page).to have_link("Download our data")
    end

    it 'should display my school menu on other pages' do
      visit home_page_path
      expect(page).to have_css("#my_school_menu")
    end

    it 'displays a printable version of the dashboard' do
      visit school_path(school, switch: true)
      click_on 'Print view'
      expect(page).to have_content("Adult dashboard for #{school.name}")
    end

    context 'and school is not data-enabled' do
      before(:each) do
        school.update!(data_enabled: false)
        visit school_path(school)
      end
      it 'should not have data enabled features in my school menu' do
        expect(page).to have_css("#my_school_menu")
        expect(page).to_not have_link("Electricity usage")
        expect(page).to_not have_link("Gas usage")
        expect(page).to_not have_link("Storage heater usage")
        expect(page).to_not have_link("Energy analysis")
        expect(page).to have_link("My alerts")
        expect(page).to have_link("School programmes")
        expect(page).to have_link("Complete pupil activities")
        expect(page).to have_link("Energy saving actions")
        expect(page).to_not have_link("Download our data")
        expect(page).to_not have_link("Review targets")
      end
    end

    context 'when school in private group' do
      before(:each) do
        school.update(school_group: create(:school_group, public: false))
      end

      it 'links to compare schools' do
        visit school_path(school, switch: true)
        within('.application') do
          expect(page).to have_link("Compare schools")
        end
      end
    end
  end

  context 'as group admin' do
    let(:school_group)  { create(:school_group) }
    let(:school)        { create(:school, name: school_name, school_group: school_group) }
    let(:user)          { create(:group_admin, school_group: school_group) }
    include_examples "navigation" do
      let(:test_school) { school }
    end
    it 'shows me the adult dashboard by default' do
      visit schools_path
      expect(page.has_content? "Energy Sparks schools across the UK").to be true
      click_on(school_name, match: :first)
      expect(page.has_link? "Pupil dashboard").to be true
    end

    it 'displays a printable report version of the page' do
      visit school_path(school, switch: true)
      click_on 'Print view'
      expect(page).to have_content("Adult dashboard for #{school.name}")
    end
    context 'when school in private group' do
      before(:each) do
        school_group.update!(public: false)
      end

      it 'links to compare schools' do
        visit school_path(school, switch: true)
        within('.application') do
          expect(page).to have_link("Compare schools")
        end
      end
    end
  end

  context 'as admin' do
    let(:user)        { create(:admin) }
    context 'and school is not data-enabled' do
      before(:each) do
        school.update!(data_enabled: false, school_group: create(:school_group))
        visit school_path(school)
      end
      it 'overrides flag and shows data-enabled links' do
        expect(page).to have_link("Compare schools")
        expect(page).to have_link("Explore data")
        expect(page).to have_link("Review energy analysis")
        expect(page).to have_link("Download your data")
      end
      it 'shows link to user view' do
        expect(page).to have_link("User view")
        click_on("User view")
        expect(page).to have_link("Admin view")
        expect(page).to_not have_link("Explore data")
      end
    end
  end
end
