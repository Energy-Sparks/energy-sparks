require 'rails_helper'

RSpec.describe 'gas out of hours advice page', type: :system do
  let(:reading_start_date) { 1.year.ago }

  let(:school) do
    create(:school, :with_basic_configuration_single_meter_and_tariffs,
      fuel_type: :gas,
      reading_start_date: reading_start_date,
      calendar: nil) # dont create a calendar initially, see nested tests
  end

  before { create(:advice_page, key: :gas_out_of_hours, fuel_type: :gas) }

  shared_examples 'a gas out of hours advice page tab' do |tab:|
    it_behaves_like 'an advice page tab', tab: tab do
      let(:key) { :gas_out_of_hours }
      let(:advice_page) { AdvicePage.find_by(key: key) }
      let(:expected_page_title) { 'Out of school hours gas use' }
    end
  end

  context 'as school admin' do
    before do
      sign_in(create(:school_admin, school: school))
      visit school_advice_gas_out_of_hours_path(school)
    end

    context 'with the default tab' do
      it_behaves_like 'a gas out of hours advice page tab', tab: 'Insights'
    end

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }

      it_behaves_like 'a gas out of hours advice page tab', tab: 'Insights'

      it 'includes introduction' do
        expect(page).to have_content(I18n.t('advice_pages.gas_out_of_hours.insights.title'))
      end

      it 'includes recommendations section' do
        expect(page).to have_content(I18n.t('advice_pages.insights.recommendations.title'))
      end

      context 'with very limited meter data' do
        let(:reading_start_date) { 1.day.ago }

        it 'displays not enough data message' do
          data_available_from = reading_start_date + 6.days
          expect(page).to have_content("Assuming we continue to regularly receive data we expect this analysis to be available after #{data_available_from.to_s(:es_short)}")
        end

        it 'does not have other sections' do
          expect(page).not_to have_content(I18n.t('advice_pages.gas_out_of_hours.insights.your_out_of_hours_usage_title'))
          expect(page).not_to have_content(I18n.t('advice_pages.gas_out_of_hours.insights.comparison.title'))
        end
      end

      context 'with more than a week of meter data' do
        let(:reading_start_date) { 30.days.ago }

        it 'includes a summary of available data' do
          expect(page).to have_content("Since #{reading_start_date.to_s(:es_short)}, 100&percnt; of your gas was used when the school was closed")
        end

        it 'previews the comparison with other schools' do
          expect(page).to have_content(I18n.t('advice_pages.gas_out_of_hours.insights.comparison.title'))

          expect(page).to have_content('As we have less than a years worth of data for your school we are not yet able to benchmark your out of hours gas consumption against other schools.')

          well_managed = BenchmarkMetrics::BENCHMARK_OUT_OF_HOURS_USE_PERCENT_GAS * 100

          expect(page).to have_content("In a year a well managed school will use less than #{well_managed.to_i}&percnt; of its gas out of hours.")

          expect(page).not_to have_css('#comparison-gas-out-of-hours')
          expect(page).not_to have_link('compare with other schools in your group')
        end
      end

      context 'with more than a years meter data' do
        it 'includes a summary of whole year' do
          expect(page).to have_content(I18n.t('advice_pages.gas_out_of_hours.insights.your_out_of_hours_usage_title'))
          expect(page).to have_content('Over the last year 100&percnt; of your gas was used when the school was closed')
        end

        it 'includes a comparison with other schools' do
          expect(page).to have_content(I18n.t('advice_pages.gas_out_of_hours.insights.comparison.title'))
          expect(page).to have_css('#comparison-gas-out-of-hours')
          expect(page).to have_link('compare with other schools in your group')
        end
      end
    end

    context "clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }

      it_behaves_like 'a gas out of hours advice page tab', tab: 'Analysis'

      it 'includes introduction' do
        expect(page).to have_content(I18n.t('advice_pages.gas_out_of_hours.analysis.summary'))
      end

      context 'with very limited meter data' do
        let(:reading_start_date) { 1.day.ago }

        it 'displays not enough data message' do
          data_available_from = reading_start_date + 6.days
          expect(page).to have_content("Assuming we continue to regularly receive data we expect this analysis to be available after #{data_available_from.to_s(:es_short)}")
        end
      end

      context 'with less than a year of meter data' do
        let(:reading_start_date) { Date.new(2024, 1, 1) }
        let(:reading_end_date)   { Date.new(2024, 1, 31) }

        it 'has last year section' do
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.analysis.recent_trend.title'))
          expect(page).not_to have_content(I18n.t('advice_pages.gas_out_of_hours.analysis.last_twelve_months.title'))
          expect(page).to have_css('#chart_wrapper_daytype_breakdown_gas_tolerant')
          expect(page).to have_css('#gas-out-of-hours-table')
        end

        it 'has by day section' do
          expect(page).to have_content(I18n.t('advice_pages.gas_out_of_hours.analysis.usage_by_day_of_week.title'))
          expect(page).to have_css('#chart_wrapper_gas_by_day_of_week_tolerant')
        end

        it 'does not have a holiday usage section' do
          expect(page).not_to have_content(I18n.t('advice_pages.gas_out_of_hours.analysis.holiday_usage.title'))
          expect(page).not_to have_css('#chart_wrapper_management_dashboard_group_by_week_gas')
          expect(page).not_to have_css('#holiday-usage-table')
        end

        context 'with school holidays defined' do
          context 'but none in period of meter data' do
            # create a number of holidays outside usage period
            let(:school) do
              create(:school, :with_basic_configuration_single_meter_and_tariffs,
                fuel_type: :gas,
                reading_start_date: reading_start_date, reading_end_date: reading_end_date,
                calendar: create(:school_calendar, :with_terms_and_holidays, term_start_date: Date.new(2022, 1, 1))
              )
            end

            it 'does not have holiday usage section' do
              expect(page).not_to have_content(I18n.t('advice_pages.gas_out_of_hours.analysis.holiday_usage.title'))
              expect(page).not_to have_css('#chart_wrapper_management_dashboard_group_by_week_gas')
              expect(page).not_to have_css('#holiday-usage-table')
            end
          end

          context 'with one holiday in period of meter data' do
            let(:school) do
              # create a number of holidays outside usage period
              calendar = create(:school_calendar, :with_terms_and_holidays, term_start_date: Date.new(2022, 1, 1))
              # but ensure there's one holiday within the period to confirm table displays
              create(:holiday, calendar: calendar, start_date: Date.new(2024, 1, 6), end_date: Date.new(2024, 1, 13))
              create(:school, :with_basic_configuration_single_meter_and_tariffs,
                fuel_type: :gas,
                reading_start_date: reading_start_date,
                reading_end_date: reading_end_date,
                calendar: calendar)
            end

            it 'has holiday usage section' do
              expect(page).to have_content(I18n.t('advice_pages.gas_out_of_hours.analysis.holiday_usage.title'))
              expect(page).to have_css('#chart_wrapper_management_dashboard_group_by_week_gas')
              expect(page).to have_css('#holiday-usage-table')
            end
          end
        end
      end

      context 'with more than a years meter data' do
        let(:reading_start_date) { 500.days.ago }

        it 'has last year section' do
          expect(page).not_to have_content(I18n.t('advice_pages.gas_long_term.analysis.recent_trend.title'))
          expect(page).to have_content(I18n.t('advice_pages.gas_out_of_hours.analysis.last_twelve_months.title'))
          expect(page).to have_css('#chart_wrapper_daytype_breakdown_gas_tolerant')
          expect(page).to have_css('#gas-out-of-hours-table')
        end

        it 'has by day section' do
          expect(page).to have_content(I18n.t('advice_pages.gas_out_of_hours.analysis.usage_by_day_of_week.title'))
          expect(page).to have_css('#chart_wrapper_gas_by_day_of_week_tolerant')
        end

        context 'with holidays defined' do
          # create a number of holidays outside usage period
          let(:school) do
            create(:school, :with_basic_configuration_single_meter_and_tariffs,
              fuel_type: :gas,
              reading_start_date: reading_start_date)
          end

          it 'has a holiday usage section' do
            expect(page).to have_content(I18n.t('advice_pages.gas_out_of_hours.analysis.holiday_usage.title'))
            expect(page).to have_css('#chart_wrapper_alert_group_by_week_gas_14_months')
            expect(page).to have_css('#holiday-usage-table')
          end
        end
      end
    end

    context "when on the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'a gas out of hours advice page tab', tab: 'Learn More'
    end
  end
end
