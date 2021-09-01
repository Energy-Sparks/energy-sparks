require 'rails_helper'

RSpec.describe "school", type: :system do

  let!(:admin)              { create(:admin)}

  let(:school_name)         { 'Oldfield Park Infants' }
  let!(:school)             { create(:school, name: school_name, latitude: 51.34062, longitude: -2.30142)}
  let!(:school_group)       { create(:school_group, name: 'School Group')}

  it 'shows me a school page' do
    visit root_path
    click_on('Schools')
    expect(page.has_content? "Energy Sparks schools across the UK").to be true
    click_on(school_name)
    expect(page.has_link? "Pupil dashboard").to be true
    expect(page.has_content? school_name).to be true
    expect(page.has_no_content? "Gas").to be true
  end

  it 'links to the pupil dashboard' do
    visit school_path(school)

    within('.sub-navbar') do
      click_on('Pupil dashboard')
    end

    expect(page.has_title? 'Pupil dashboard').to be true
    expect(page.has_link? "Adult dashboard").to be true
    expect(page.has_content? school_name).to be true
  end

  context 'with school in group' do
    let(:public)      { true }

    before(:each) do
      school.update(school_group: create(:school_group, public: public))
    end

    it 'links to compare schools in public groups' do
      visit school_path(school)
      expect(page).to have_link("Compare schools")
    end

    context 'and group is private' do
      let(:public)      { false }

      it 'doesnt link to compare schools' do
        visit school_path(school)
        expect(page).to_not have_link("Compare schools")
      end

      context 'and signed in as school user' do
        let!(:school_admin)          { create(:school_admin, school: school) }
        before(:each) do
          sign_in(school_admin)
        end
        it 'links to compare schools' do
          visit school_path(school)
          expect(page).to have_link("Compare schools")
        end
      end
    end
  end

  context 'with invisible school' do
    let!(:school_invisible)       { create(:school, name: 'Invisible School', visible: false, school_group: school_group)}

    context "as guest user" do
      it 'does not show invisible school or the group' do
        visit root_path
        click_on('Schools')
        expect(page.has_content? school_name).to be true
        expect(page.has_content? 'Invisible School').to_not be true
        expect(page.has_content? 'School Group').to_not be true
      end

      it 'prompts user to login when viewing' do
        visit school_path(school_invisible)
        expect(page.has_content? 'You are not authorized to access this page').to be true
      end

    end

    context 'as admin' do
      before(:each) do
        sign_in(admin)
        visit root_path
        click_on('Schools')
      end

      it 'does show invisible school, but not the group' do
        expect(page.has_content? school_name).to be true
        expect(page.has_content? 'Not visible schools').to be true
        expect(page.has_content? 'Invisible School').to be true
        expect(page.has_content? 'School Group').to_not be true
      end

      it 'shows school' do
        visit school_path(school_invisible)
        expect(page.has_link? "Pupil dashboard").to be true
        expect(page.has_content? school_invisible.name).to be true
      end

    end

  end

  context 'non-public school' do
    let!(:non_public_school)       { create(:school, name: 'Non-public School', visible: true, public: false, school_group: school_group)}

    context 'as unknown user' do

      it 'is listed on school page' do
        visit root_path
        click_on('Schools')

        expect(page.has_content? non_public_school.name).to be true
        expect(page.has_content? 'School Group').to be true
      end

      it 'prompts user to login when viewing' do
        visit school_path(non_public_school)
        expect(page.has_content? 'This school has disabled public access').to be true
      end
    end

    context 'as staff' do
      let!(:school_admin)          { create(:school_admin, school: non_public_school) }

      before(:each) do
        sign_in(school_admin)
      end

      it 'displays the school page' do
        visit school_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link("Compare schools")
      end

      it 'redirects away user from the /private page' do
        visit school_private_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link("Compare schools")
      end

    end

    context 'as a user in the same school group' do
      let!(:school_in_same_group)   { create(:school, name: 'Same Group School', visible: true, school_group: school_group)}
      let!(:other_admin)            { create(:school_admin, school: school_in_same_group) }

      before(:each) do
        sign_in(other_admin)
      end

      it 'displays the school page' do
        visit school_path(non_public_school)
        expect(page).to have_content(non_public_school.name)
        expect(page).to have_link("Compare schools")
      end

    end

    context 'as a unrelated school user' do
      let!(:other_admin)    { create(:school_admin) }
      before(:each) do
        sign_in(other_admin)
      end

      it 'prompts user to login when viewing' do
        visit school_path(non_public_school)
        expect(page.has_content? 'This school has disabled public access').to be true
      end

    end

  end

  context 'with partners' do

    let(:partner)             { create(:partner, name: "School Sponsor", url: "http://example.org") }
    let(:other_partner)       { create(:partner, name: "Big Tech Co", url: "https://example.com") }

    before(:each) do
      school.update!( {school_group: school_group })
    end

    it 'displays school group partners' do
      school.school_group.partners << partner
      visit school_path(school)
      expect(page).to have_link("School Sponsor", href: "http://example.org")
    end

    it 'displays school partners' do
      school.partners << partner
      visit school_path(school)
      expect(page).to have_link("School Sponsor", href: "http://example.org")
    end

    it 'displays all partners' do
      school.school_group.partners << partner
      school.partners << other_partner
      visit school_path(school)
      expect(page).to have_link("School Sponsor", href: "http://example.org")
      expect(page).to have_link("Big Tech Co", href: "https://example.com")
    end

  end

  context 'as an admin' do
    before(:each) do
      sign_in(admin)
      visit root_path
      expect(page.has_content? 'Sign Out').to be true
      click_on('Schools')
      expect(page.has_content? "Energy Sparks schools across the UK").to be true
    end

    # describe 'school with gas meter' do
    #   it 'shows me a school page' do
    #     school.configuration.update(gas_dashboard_chart_type: Schools::Configuration::TEACHERS_GAS_SIMPLE)
    #     click_on(school_name)
    #     expect(page.has_content? "Gas").to be true
    #     expect(page.has_content? "Electricity").to be false
    #   end
    # end
    #
    # describe 'school with electricity meter' do
    #   it 'shows me a school page' do
    #     school.configuration.update(electricity_dashboard_chart_type: Schools::Configuration::TEACHERS_ELECTRICITY, fuel_configuration: Schools::FuelConfiguration.new(has_electricity: true, has_gas: false))
    #     click_on(school_name)
    #     expect(page.has_content? "Gas").to be false
    #     expect(page.has_content? "Electricity").to be true
    #   end
    # end
    #
    # describe 'school with both meters' do
    #   it 'shows me a school page with both meters' do
    #     school.configuration.update(gas_dashboard_chart_type: Schools::Configuration::TEACHERS_GAS_SIMPLE, electricity_dashboard_chart_type: Schools::Configuration::TEACHERS_ELECTRICITY, fuel_configuration: Schools::FuelConfiguration.new(has_electricity: true, has_gas: true))
    #     click_on(school_name)
    #     expect(page.has_content? school_name).to be true
    #     expect(page.has_content? "Gas").to be true
    #     expect(page.has_content? "Electricity").to be true
    #   end
    # end

    describe 'managing a school' do

      let!(:ks1)                { KeyStage.create(name: 'KS1') }
      let!(:ks2)                { KeyStage.create(name: 'KS2') }
      let!(:ks3)                { KeyStage.create(name: 'KS3') }

      context 'and updating the school configuration' do

        it 'I can set up a school for KS1' do
          click_on(school_name)
          click_on('Edit school details')
          expect(school.key_stages).to_not include(ks1)
          expect(school.key_stages).to_not include(ks2)
          expect(school.key_stages).to_not include(ks3)

          check('KS1')
          click_on('Update School')
          school.reload
          expect(school.key_stages).to include(ks1)
          expect(school.key_stages).to_not include(ks2)
          expect(school.key_stages).to_not include(ks3)
        end

        it 'I can set up a school for KS1 and KS2' do
          click_on(school_name)
          click_on('Edit school details')
          expect(school.key_stages).to_not include(ks1)
          expect(school.key_stages).to_not include(ks2)
          expect(school.key_stages).to_not include(ks3)

          check('KS1')
          check('KS2')
          click_on('Update School')
          school.reload
          expect(school.key_stages).to include(ks1)
          expect(school.key_stages).to include(ks2)
          expect(school.key_stages).to_not include(ks3)
        end

        it 'can see when the school was created on Energy Sparks' do
          click_on(school_name)
          click_on('Edit school details')
          date = school.created_at
          expect(page).to have_content "#{school.name} was created on #{date.strftime('%a')} #{date.day.ordinalize} #{date.strftime('%b %Y')}"
        end

        it 'can edit lat/lng' do
          click_on(school_name)
          click_on('Edit school details')

          fill_in 'Latitude', with: '52.123'
          fill_in 'Longitude', with: '-1.123'
          click_on('Update School')

          school.reload
          expect(school.latitude.to_s).to eq('52.123')
          expect(school.longitude.to_s).to eq('-1.123')
        end

        it 'can create an active date' do
          click_on(school_name)
          click_on('Edit school details')

          expect(school.observations).to be_empty

          expect(page).to have_field('Activation date')
          activation_date = Date.parse('01/01/2020')

          fill_in 'Activation date', with: activation_date.strftime("%d/%m/%Y")
          click_on('Update School')

          expect(school.observations.first.description.to_s).to include("became an active user of Energy Sparks!")

          school.reload
          expect(school.activation_date).to eq activation_date

          click_on('Edit school details')
          fill_in 'Activation date', with: ''
          click_on('Update School')

          school.reload
          expect(school.activation_date).to eq nil
        end

        context "can update storage heaters" do
          before(:each) do
            allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
          end

          it "and changes are saved" do
            click_on(school_name)
            click_on('Edit school details')
            check 'Our school has night storage heaters'

            click_on('Update School')

            school.reload
            expect(school.indicated_has_storage_heaters).to be true
          end

          it "and user is prompted to review target" do
            create(:school_target, school: school, storage_heaters: nil)

            click_on(school_name)
            click_on('Edit school details')
            check 'Our school has night storage heaters'

            click_on('Update School')

            school.reload
            expect(school.has_school_target_event?(:storage_heater_added)).to be true

            visit school_path(school)
            expect(page).to have_content("The configuration of your school has changed, you may need to revisit your targets for this year.")
          end
        end

      end

      it 'allows public/non-public management from school page' do
        click_on(school_name)
        click_on('Public')
        school.reload
        expect(school).to_not be_public
        click_on('Not Public')
        school.reload
        expect(school).to be_public
      end

      it 'allows visibility management from school page' do
        click_on(school_name)
        click_on('Visible')
        school.reload
        expect(school).to_not be_visible
        click_on('Not visible')
        school.reload
        expect(school).to be_visible
      end

      it 'allows data process management' do
        create(:gas_meter, :with_unvalidated_readings, school: school)
        school.update(process_data: false)
        click_on(school_name)
        click_on('Not processing data')
        expect(page).to have_content "#{school.name} will now process data"
        school.reload
        expect(school.process_data).to eq(true)
        click_on('Processing data')
        school.reload
        expect(school.process_data).to eq(false)
      end

      it 'disallows data process management if the school has no meter readings' do
        school.update(process_data: false)
        click_on(school_name)
        click_on('Not processing data')
        expect(page).to have_content "#{school.name} cannot process data as it has no meter readings"
        school.reload
        expect(school.process_data).to eq(false)
      end

    end
  end
end
