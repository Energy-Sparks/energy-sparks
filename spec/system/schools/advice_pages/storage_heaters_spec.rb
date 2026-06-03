require 'rails_helper'

RSpec.describe 'storage heaters advice page', type: :system do
  let(:key) { 'storage_heaters' }
  let(:expected_page_title) { 'Storage heater usage analysis' }

  include_context 'storage advice page'

  it_behaves_like 'it responds to HEAD requests'

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }
    let(:school_period) { Holiday.new(:xmas, 'Xmas 2021/2022', Date.new(2021, 12, 18), Date.new(2022, 0o1, 3), nil) }
    let(:holiday_usage) do
      OpenStruct.new(
        usage: CombinedUsageMetric.new(
          £: 12.0,
          kwh: 12.0,
          co2: 12.0,
          percent: 0.4
        ),
        previous_holiday: nil,
        previous_holiday_usage: nil
      )
    end

    before do
      combined_usage_metric = CombinedUsageMetric.new(
        £: 12.0,
        kwh: 12.0,
        co2: 12.0,
        percent: 0.4
      )

      allow_any_instance_of(Usage::UsageBreakdownService).to receive(:usage_breakdown) do
        Usage::UsageBreakdown.new(
          holiday: combined_usage_metric,
          school_day_closed: combined_usage_metric,
          school_day_open: combined_usage_metric,
          weekend: combined_usage_metric,
          out_of_hours: combined_usage_metric,
          community: combined_usage_metric,
          fuel_type: :storage_heater
        )
      end
      allow_any_instance_of(Usage::UsageBreakdown).to receive(:total) { combined_usage_metric }
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
          predicted_kwh_for_low_average_outside_temperature: 680.44
        )
      }

      allow(meter_collection).to receive(:holidays).and_return(nil)
      school_holiday_calendar_comparison = {
        school_period => holiday_usage
      }
      allow_any_instance_of(Usage::HolidayUsageCalculationService).to receive(:school_holiday_calendar_comparison) { school_holiday_calendar_comparison }

      sign_in(user)
      visit school_advice_storage_heaters_path(school)
    end

    it_behaves_like 'an advice page tab', tab: 'Insights'

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }

      it_behaves_like 'an advice page tab', tab: 'Insights'
    end

    context "clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }

      it_behaves_like 'an advice page tab', tab: 'Analysis'
      it 'shows expected content' do
        expect(page).to have_css('#chart_wrapper_storage_heater_group_by_week')
        expect(page).to have_css('#chart_wrapper_storage_heater_by_day_of_week_tolerant')
        expect(page).to have_css('#chart_wrapper_storage_heater_intraday_current_year')
        expect(page).to have_css('#chart_wrapper_intraday_line_school_last7days_storage_heaters')
        expect(page).to have_css('#chart_wrapper_storage_heater_group_by_week_long_term')
        expect(page).to have_css('#chart_wrapper_heating_on_off_by_week_storage_heater')
        expect(page).to have_css('#chart_wrapper_storage_heater_thermostatic')
        within '#chart_wrapper_storage_heater_thermostatic' do
          expect(page).not_to have_css('.axis-choice')
        end
        expect(page).to have_content('Storage heater use during holidays')
        expect(page).to have_content(Date.new(2021, 12, 18).to_fs(:es_short))
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'an advice page tab', tab: 'Learn More'
    end
  end
end
