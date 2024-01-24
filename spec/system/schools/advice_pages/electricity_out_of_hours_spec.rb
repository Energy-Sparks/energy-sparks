require 'rails_helper'

RSpec.describe "electricity out of hours advice page", type: :system do
  let(:key) { 'electricity_out_of_hours' }
  let(:expected_page_title) { "Out of school hours electricity use" }

  include_context "electricity advice page"

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }
    let(:school_period) { Holiday.new(:xmas, "Xmas 2021/2022", Date.new(2021, 12, 18), Date.new(2022, 0o1, 3), nil) }
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
          fuel_type: :electricity
        )
      end
      allow_any_instance_of(Usage::UsageBreakdown).to receive(:total) { combined_usage_metric }
      #allow_any_instance_of(Usage::UsageBreakdown).to receive(:potential_savings) { combined_usage_metric }

      allow(meter_collection).to receive(:holidays).and_return(nil)

      school_holiday_calendar_comparison = {
        school_period => holiday_usage
      }

      allow_any_instance_of(Usage::HolidayUsageCalculationService).to receive(:school_holiday_calendar_comparison) { school_holiday_calendar_comparison }

      sign_in(user)
      visit school_advice_electricity_out_of_hours_path(school)
    end

    it_behaves_like "an advice page tab", tab: "Insights"

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }

      it_behaves_like "an advice page tab", tab: "Insights"

      it 'shows expected content' do
        expect(page).to have_content('What is out of hours usage?')
        expect(page).to have_content('Your out of hours usage')
        expect(page).to have_content('How do you compare?')
        expect(page).to have_content('What should you do next?')
        expect(page).to have_content('Exemplar')
        expect(page).to have_content('12')
      end
    end

    context "clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }

      it_behaves_like "an advice page tab", tab: "Analysis"

      it 'shows expected content' do
        expect(page).to have_content('Last 12 months')
        expect(page).to have_content('Usage by day of week')
        expect(page).to have_content('12')
        expect(page).to have_content('Holiday')
        expect(page).to have_css('#chart_wrapper_daytype_breakdown_electricity_tolerant')
        expect(page).to have_css('#chart_wrapper_electricity_by_day_of_week_tolerant')
        expect(page).to have_content("Holiday usage")
        expect(page).to have_content(Date.new(2021, 12, 18).to_s(:es_short))
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like "an advice page tab", tab: "Learn More"
    end
  end
end
