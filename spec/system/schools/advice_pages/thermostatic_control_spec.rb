require 'rails_helper'

RSpec.describe "thermostatic control advice page", type: :system do
  let(:key) { 'thermostatic_control' }
  let(:expected_page_title) { "Advanced thermostatic control analysis" }
  include_context "gas advice page"

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }

    before do
      sign_in(user)

      allow_any_instance_of(Schools::Advice::ThermostaticControlController).to receive(:build_heating_thermostatic_analysis) {
        OpenStruct.new(
          r2: 0.6743665142232793,
          insulation_hotwater_heat_loss_estimate_kwh: 193133.95130872616,
          insulation_hotwater_heat_loss_estimate_£: 5794.0185392617805,
          average_heating_school_day_a: 5812.076809865945,
          average_heating_school_day_b: -326.0646866043404,
          average_outside_temperature_high: 12.0,
          average_outside_temperature_low: 4.0,
          predicted_kwh_for_high_average_outside_temperature: 1899.3005706138597,
          predicted_kwh_for_low_average_outside_temperature: 4507.818063448583
        )
      }

      visit school_advice_thermostatic_control_path(school)
    end

    it_behaves_like "an advice page tab", tab: "Insights"

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }
      it_behaves_like "an advice page tab", tab: "Insights"
    end
    context "clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }
      it_behaves_like "an advice page tab", tab: "Analysis"
    end
    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }
      it_behaves_like "an advice page tab", tab: "Learn More"
    end
  end
end
