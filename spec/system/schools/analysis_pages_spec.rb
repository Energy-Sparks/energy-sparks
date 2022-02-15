require 'rails_helper'

RSpec.describe "analysis page", type: :system do
  let!(:school_group) { create(:school_group) }
  let!(:school) { create(:school, school_group: school_group) }

  let(:description) { 'all about this alert type' }
  let!(:gas_fuel_alert_type) { create(:alert_type, source: :analysis, sub_category: :heating, fuel_type: :gas, description: description, frequency: :weekly) }
  let!(:gas_meter) { create :gas_meter_with_reading, school: school }

  context 'with generated alert' do

    let!(:alert_type_rating) do
      create(
        :alert_type_rating,
        alert_type: gas_fuel_alert_type,
        rating_from: 0,
        rating_to: 10,
        analysis_active: true
      )
    end

    let!(:alert_type_rating_content_version) do
      create(
        :alert_type_rating_content_version,
        alert_type_rating: alert_type_rating,
        analysis_title: 'You might want to think about heating',
        analysis_subtitle: 'This is what you need to do'
      )
    end

    let!(:alert) { create(:alert, :with_run, alert_type: gas_fuel_alert_type, school: school, rating: 9.0) }

    before do
      Alerts::GenerateContent.new(school).perform

      allow_any_instance_of(SchoolAggregation).to receive(:aggregate_school).and_return(school)

      adapter = double(:adapter)
      allow(Alerts::FrameworkAdapter).to receive(:new).with(alert_type: gas_fuel_alert_type, school: school, analysis_date: alert.run_on, aggregate_school: school).and_return(adapter)
      allow(adapter).to receive(:has_structured_content?).and_return(false)

      allow(adapter).to receive(:content).and_return(
        [
          {type: :enhanced_title, content: { title: 'Heating advice', rating: 10.0 }},
          {type: :html, content: '<h2>Turn your heating down</h2>'},
          {type: :chart_name, content: :benchmark},
          {type: :chart_name, content: :last_2_weeks_carbon_emissions, mpan_mprn: 1234567890}
        ]
      )
    end

    context 'as normal user, no restrictions' do

      let!(:user)  { create(:staff, staff_role: create(:staff_role, :teacher), school: school)}

      before(:each) do
        sign_in(user)

        visit school_path(school)
        click_on "Review your energy analysis"

        expect(page).to have_content('You might want to think about heating')
        expect(page).to have_content("This is what you need to do")
        expect(page).to have_link("Compare schools")

        expect(page.all('.fas.fa-star').size).to eq(4)
        expect(page.all('.fas.fa-star-half-alt').size).to eq(1)
      end

      it 'shows the box on the page with the relevant template data' do
        click_on alert_type_rating_content_version.analysis_title
        within 'h1' do
          expect(page).to have_content('Heating advice')
        end
        within 'h2' do
          expect(page).to have_content('Turn your heating down')
        end
      end

      it 'allows a school related user to access a restricted alert' do
        gas_fuel_alert_type.update!(user_restricted: true)
        click_on alert_type_rating_content_version.analysis_title
        within 'h1' do
          expect(page).to have_content('Heating advice')
        end
        within 'h2' do
          expect(page).to have_content('Turn your heating down')
        end
      end
    end

    context 'as non school related user, restricted' do
      before do
        visit school_path(school)
        click_on "Review energy analysis"

        expect(page).to have_content('You might want to think about heating')
        expect(page).to have_content("This is what you need to do")

        expect(page.all('.fas.fa-star').size).to eq(4)
        expect(page.all('.fas.fa-star-half-alt').size).to eq(1)

        gas_fuel_alert_type.update!(user_restricted: true)
      end

      it 'redirects the user with a message if it is user restricted and the user is not the right type' do
        click_on alert_type_rating_content_version.analysis_title
        expect(page).to have_content('Only an admin or staff user for this school can access this content')
        within 'h1' do
          expect(page).to_not have_content('Heating advice')
        end
      end
    end

    context 'as school group user, restricted' do

      let(:school_group) { create(:school_group) }
      let(:group_admin)  { create(:group_admin, school_group: school_group) }

      before do
        school.update(school_group: school_group)

        sign_in(group_admin)
        visit school_path(school)
        click_on "Review energy analysis"

        expect(page).to have_content('You might want to think about heating')
        expect(page).to have_content("This is what you need to do")

        expect(page.all('.fas.fa-star').size).to eq(4)
        expect(page.all('.fas.fa-star-half-alt').size).to eq(1)

        gas_fuel_alert_type.update!(user_restricted: true)
      end

      it 'it allows the content to be viewed' do
        click_on alert_type_rating_content_version.analysis_title
        within 'h1' do
          expect(page).to have_content('Heating advice')
        end
        within 'h2' do
          expect(page).to have_content('Turn your heating down')
        end
        expect(page.find('#chart_benchmark')).to_not be_nil
      end

      it 'produces right chart elements' do
        click_on alert_type_rating_content_version.analysis_title
        expect(page.find('#chart_benchmark')).to_not be_nil
        expect(page.find('#chart_last_2_weeks_carbon_emissions_1234567890')).to_not be_nil

      end
    end

    context 'when viewing page with error' do

      before(:each) do
        # content will raise error
        adapter = double(:adapter)
        allow(Alerts::FrameworkAdapter).to receive(:new).and_return(adapter)
        allow(adapter).to receive(:content).and_raise(EnergySparksNoMeterDataAvailableForFuelType.new('broken alert'))
      end

      it 'shows message' do
        visit school_analysis_path(school, school.latest_analysis_pages.last)
        expect(page).to have_content('Analysis page raised error: broken alert')
        expect(page).to have_link('Back')
      end
    end

  end
end
