require 'rails_helper'

RSpec.describe "storage heaters advice page", type: :system do
  let(:key) { 'storage_heaters' }
  let(:expected_page_title) { "Storage heater usage analysis" }
  include_context "storage advice page"

  context 'as school admin' do
    let(:user)  { create(:school_admin, school: school) }

    before do
      combined_usage_metric = CombinedUsageMetric.new(
        £: 12.0,
        kwh: 12.0,
        co2: 12.0,
        percent: 0.4
      )

      allow_any_instance_of(Usage::AnnualUsageBreakdownService).to receive(:usage_breakdown) do
        Usage::AnnualUsageCategoryBreakdown.new(
          holiday: combined_usage_metric,
          school_day_closed: combined_usage_metric,
          school_day_open: combined_usage_metric,
          weekend: combined_usage_metric,
          out_of_hours: combined_usage_metric,
          community: combined_usage_metric,
          fuel_type: :storage_heater
        )
      end
      allow_any_instance_of(Usage::AnnualUsageCategoryBreakdown).to receive(:total) { combined_usage_metric }
      allow_any_instance_of(Usage::AnnualUsageCategoryBreakdown).to receive(:potential_savings) { combined_usage_metric }
      allow_any_instance_of(Heating::SeasonalControlAnalysisService).to receive(:seasonal_analysis) {
        OpenStruct.new(
          estimated_savings: combined_usage_metric,
          heating_on_in_warm_weather_days: 16.0,
          percent_of_annual_heating: 0.05
        )
      }

      allow_any_instance_of(Heating::HeatingThermostaticAnalysisService).to receive(:create_model) {
        OpenStruct.new(
          r2: 0.37,
          insulation_hotwater_heat_loss_estimate_kwh: 16240.67,
          insulation_hotwater_heat_loss_estimate_£: 2436.1,
          average_heating_school_day_a: 798.72,
          average_heating_school_day_b: -29.57,
          average_outside_temperature_high: 12.0,
          average_outside_temperature_low: 4.0,
          predicted_kwh_for_high_average_outside_temperature: 443.88,
          predicted_kwh_for_low_average_outside_temperature:680.44
        )
      }

      sign_in(user)
      visit school_advice_storage_heaters_path(school)
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
