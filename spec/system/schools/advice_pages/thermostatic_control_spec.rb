require 'rails_helper'

RSpec.describe 'thermostatic control advice page', type: :system do
  let(:key) { 'thermostatic_control' }
  let(:expected_page_title) { 'Thermostatic control analysis' }

  include_context 'gas advice page'

  it_behaves_like 'it responds to HEAD requests'

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }

    before do
      sign_in(user)

      allow_any_instance_of(Schools::Advice::ThermostaticAnalysisService).to receive_messages(
        {
          enough_data?: true,
          thermostatic_analysis: OpenStruct.new(
            r2: 0.6743665142232793,
            insulation_hotwater_heat_loss_estimate_kwh: 193_133.95130872616,
            insulation_hotwater_heat_loss_estimate_£: 5794.0185392617805,
            average_heating_school_day_a: 5812.076809865945,
            average_heating_school_day_b: -326.0646866043404,
            average_outside_temperature_high: 12.0,
            average_outside_temperature_low: 4.0,
            predicted_kwh_for_high_average_outside_temperature: 1899.3005706138597,
            predicted_kwh_for_low_average_outside_temperature: 4507.818063448583
        )
      })

      visit school_advice_thermostatic_control_path(school)
    end

    it_behaves_like 'an advice page tab', tab: 'Insights'

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }

      it_behaves_like 'an advice page tab', tab: 'Insights'

      it 'shows expected content' do
        expect(page).to have_content('What is thermostatic control?')
        expect(page).to have_content('How do you compare?')
        expect(page).to have_content('Your thermostatic control is 0.67, which is about average')
      end
    end

    context "clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }

      it_behaves_like 'an advice page tab', tab: 'Analysis'

      it 'shows expected content' do
        expect(page).to have_content('Analysis')
        expect(page).to have_content('Thermostatic control in your school')
        expect(page).to have_content('How to calculate a theoretical daily gas consumption using the model')
        expect(page).to have_content('Your thermostatic control is 0.67, which is about average')
        expect(page).to have_content('Using days with large diurnal range to understand thermostatic control')
        expect(page).to have_content("Your school's R² value is 0.67 which is about average")
        expect(page).to have_css('#chart_wrapper_thermostatic_up_to_1_year')
        expect(page).to have_css('#chart_wrapper_thermostatic_control_large_diurnal_range')

        ['#chart_wrapper_thermostatic_up_to_1_year', '#chart_wrapper_thermostatic_control_large_diurnal_range'].each do |chart_type|
          within chart_type do
            expect(page).not_to have_css('.axis-choice', visible: :hidden)
          end
        end
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'an advice page tab', tab: 'Learn More'
    end
  end
end
