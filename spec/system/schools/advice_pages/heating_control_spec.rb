require 'rails_helper'

RSpec.describe 'heating control advice page', type: :system do
  let(:key) { 'heating_control' }
  let(:expected_page_title) { 'Heating control analysis' }
  include_context 'gas advice page'

  let(:enough_data) { true }
  let(:enough_data_for_seasonal_analysis) { true }
  let(:average_start_time_last_week) { TimeOfDay.new(4, 0) }
  let(:percentage_of_annual_gas) { 0.07 }
  let(:estimated_savings) { CombinedUsageMetric.new(kwh: 673, £: 1234, co2: 4567) }
  let(:date) { Time.zone.today - 1}
  let(:day) do
    OpenStruct.new(
      date: date,
      heating_start_time: TimeOfDay.new(5, 0),
      recommended_time: TimeOfDay.new(6, 0),
      temperature: 12.1,
      saving: CombinedUsageMetric.new(kwh: 100, £: 50, co2: 20)
    )
  end
  let(:last_week_start_times) { Heating::HeatingStartTimes.new(days: [day, day, day], average_start_time: average_start_time_last_week) }

  let(:seasonal_analysis) do
    OpenStruct.new(
      heating_on_in_warm_weather_days: 42,
      percent_of_annual_heating: 0.02,
      estimated_savings: CombinedUsageMetric.new(kwh: 500, £: 500, co2: 200)
    )
  end

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }

    before do
      allow_any_instance_of(Schools::Advice::HeatingControlService).to receive_messages(
        enough_data?: enough_data,
        average_start_time_last_week: average_start_time_last_week,
        percentage_of_annual_gas: percentage_of_annual_gas,
        estimated_savings: estimated_savings,
        enough_data_for_seasonal_analysis?: enough_data_for_seasonal_analysis,
        last_week_start_times: last_week_start_times,
        seasonal_analysis: seasonal_analysis
      )

      sign_in(user)
      visit school_advice_heating_control_path(school)
    end

    it_behaves_like 'an advice page tab', tab: 'Insights'

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }

      it_behaves_like 'an advice page tab', tab: 'Insights'
      it 'includes expected sections' do
        expect(page).to have_content(I18n.t('advice_pages.heating_control.insights.title'))
        expect(page).to have_content(I18n.t('advice_pages.heating_control.insights.comparison.title'))
        expect(page).to have_content(I18n.t('advice_pages.heating_control.insights.controls.title'))
        expect(page).to have_content(I18n.t('advice_pages.heating_control.insights.warm_weather.title'))
      end

      it 'includes expected data' do
        expect(page).to have_content('the average start time for your heating')
        expect(page).to have_content('04:00')
        expect(page).to have_content('£1,234')
        expect(page).to have_content('42')
      end

      context 'and theres is no average start time' do
        let(:last_week_start_times) { Heating::HeatingStartTimes.new(days: [day, day, day], average_start_time: nil) }

        it 'does not show that text' do
          expect(page).not_to have_content('the average start time for your heating')
        end
      end
    end

    context "clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }

      it_behaves_like 'an advice page tab', tab: 'Analysis'
      it 'includes expected sections' do
        expect(page).to have_content(I18n.t('advice_pages.heating_control.analysis.heating_timings.title'))
        expect(page).to have_content(I18n.t('advice_pages.heating_control.analysis.school_day_heating.title'))
        expect(page).to have_content(I18n.t('advice_pages.heating_control.analysis.seasonal_control.title'))
        expect(page).not_to have_content(I18n.t('advice_pages.heating_control.analysis.meter_breakdown.title'))
      end

      it 'includes expected charts' do
        expect(page).to have_css('#chart_wrapper_gas_heating_season_intraday_up_to_1_year')
        expect(page).to have_css('#chart_wrapper_heating_on_off_by_week')
      end

      it 'includes expected data in table' do
        expect(page).to have_css('#heating-start-times')
        within('#heating-start-times') do
          expect(page).to have_content(date.to_fs(:es_full))
          expect(page).to have_content('12')
          expect(page).to have_content('05:00')
          expect(page).to have_content('06:00')
          expect(page).to have_content('too early')
        end
      end

      context 'when heating start times are ok' do
        let(:day) do
          OpenStruct.new(
            date: date,
            heating_start_time: TimeOfDay.new(5, 0),
            recommended_time: TimeOfDay.new(0, 0),
            temperature: 3.8,
            saving: CombinedUsageMetric.new(kwh: 100, £: 50, co2: 20)
          )
        end

        it 'includes expected data in table' do
          expect(page).to have_css('#heating-start-times')
          within('#heating-start-times') do
            expect(page).to have_content(date.to_fs(:es_full))
            expect(page).to have_content('4')
            expect(page).to have_content('05:00')
            expect(page).to have_content('-')
            expect(page).to have_content('on time')
          end
        end
      end

      it 'includes expected data in seasonal analysis' do
        expect(page).to have_content('£1,234')
        expect(page).to have_content('42')
      end

      context 'and theres is no average start time' do
        let(:last_week_start_times) { Heating::HeatingStartTimes.new(days: [day, day, day], average_start_time: nil) }

        it 'does not show the table' do
          expect(page).not_to have_content(I18n.t('advice_pages.heating_control.analysis.heating_timings.intro_html '))
          expect(page).not_to have_css('#heating-start-times')
        end
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'an advice page tab', tab: 'Learn More'
    end
  end
end
