require 'rails_helper'

RSpec.describe 'Baseload advice page', type: :system do
  let(:key) { 'baseload' }
  let(:expected_page_title) { 'Baseload analysis' }

  include_context 'electricity advice page'

  it_behaves_like 'it responds to HEAD requests'

  context 'as a school admin' do
    let(:user)  { create(:school_admin, school: school) }

    before do
      sign_in(user)
      visit school_advice_path(school)
    end

    context 'when viewing the learn more page' do
      before do
        visit learn_more_school_advice_baseload_path(school)
      end

      it_behaves_like 'an advice page tab', tab: 'Learn More'

      context 'with no recent data' do
        let(:start_date)  { Time.zone.today - 24.months }
        let(:end_date)    { Time.zone.today - 2.months }

        before { refresh }

        it_behaves_like 'an advice page NOT showing electricity data warning'
      end
    end

    context 'when viewing the analysis' do
      let(:average_baseload_kw) { 2.4 }
      let(:average_baseload_kw_benchmark) { 2.1 }
      let(:usage) { double(kwh: 123.0, £: 456.0, co2: 789.0, percent: 0.2) }
      let(:savings) { double(kwh: 11.0, £: 22.0, co2: 33.0) }
      let(:annual_average_baseload) { { year: 2020, baseload_usage: usage } }
      let(:baseload_meter_breakdown) { {} }
      let(:seasonal_variation) do
        double(winter_kw: 1, summer_kw: 2, percentage: 3, estimated_saving_£: 4, estimated_saving_co2: 5,
               variation_rating: 6)
      end
      let(:seasonal_variation_by_meter) { {} }
      let(:intraweek_variation) do
        double(max_day_kw: 1, min_day_kw: 2, percent_intraday_variation: 3, estimated_saving_£: 4, estimated_saving_co2: 5,
               variation_rating: 6, min_day: 0, max_day: 1)
      end
      let(:intraweek_variation_by_meter) { {} }

      before do
        # stub calls to service so we can test the controller/view logic
        allow_any_instance_of(Schools::Advice::BaseloadService).to receive_messages(
          {
            average_baseload_kw: average_baseload_kw,
            average_baseload_kw_benchmark: average_baseload_kw_benchmark,
            annual_baseload_usage: usage,
            estimated_savings: savings,
            annual_average_baseloads: [annual_average_baseload],
            baseload_meter_breakdown: baseload_meter_breakdown,
            seasonal_variation: seasonal_variation,
            seasonal_variation_by_meter: seasonal_variation_by_meter,
            intraweek_variation: intraweek_variation,
            intraweek_variation_by_meter: intraweek_variation_by_meter
          }
        )

        visit analysis_school_advice_baseload_path(school)
      end

      it_behaves_like 'an advice page tab', tab: 'Analysis'

      it 'has the expected sections' do
        expect(page).to have_content('Recent trend')
        expect(page).to have_content('Long term trend')
        expect(page).to have_content('Seasonal variation')
        expect(page).to have_content('Variation in baseload between days of week')
      end

      it 'shows analysis content' do
        within '.advice-page-tabs' do
          expect(page).to have_content('baseload over the last 12 months was 2.4 kW')
          expect(page).to have_content('Your baseload represents 20&percnt; of your annual consumption')
        end
      end

      it 'shows the how have we analysed your data modal' do
        first(:link, 'How did we calculate these figures?').click
        expect(page).to have_content('How have we analysed your data?')
        expect(page).to have_content('School characteristics')
        expect(page).to have_content('Cost calculations')
        expect(page).to have_content('Your electricity tariffs have changed in the last year, the last change was on 01 Sep 2022, before this date the average tariff was 15p/kWh, and since it is £3.10/kWh. This will increase your electricity costs by 1,900&percnt; going forwards')
        expect(page).to have_content('School comparisons')
        expect(page).to have_content('"Exemplar" schools represent the top 17.5% of Energy Sparks schools')
      end

      context 'with limited data' do
        let(:start_date)  { Date.parse('28/09/2022') }
        let(:end_date)    { Date.parse('30/05/2023') }

        # Note ((Date.parse('30/05/2023') - Date.parse('28/09/2022')).to_f / 365 * 12) => 8.021917808219179
        before do
          visit analysis_school_advice_baseload_path(school)
        end

        it 'shows different message' do
          expect(page).to have_content('8 months')
        end
      end

      context 'with no recent data' do
        let(:start_date)  { Time.zone.today - 24.months }
        let(:end_date)    { Time.zone.today - 2.months }

        before { refresh }

        it_behaves_like 'an advice page showing electricity data warning'
      end
    end

    context 'when viewing the insights' do
      let(:average_baseload_last_year_kw) { 2.1 }
      let(:average_baseload_last_week_kw) { 2.2 }

      let(:average_baseload_kw_exemplar) { 1.1 }
      let(:average_baseload_kw_benchmark) { 2.4 }

      let(:previous_year_average_baseload_kw) { 2.0 }
      let(:previous_week_average_baseload_kw) { 1.9 }

      let(:comparison) do
        Schools::Comparison.new(
          school_value: average_baseload_last_year_kw,
          benchmark_value: average_baseload_kw_benchmark,
          exemplar_value: average_baseload_kw_exemplar,
          unit: :kw
        )
      end

      before do
        # current baseload
        allow_any_instance_of(Schools::Advice::BaseloadService).to receive(:average_baseload_kw).with(period: :year).and_return average_baseload_last_year_kw
        allow_any_instance_of(Schools::Advice::BaseloadService).to receive(:average_baseload_kw).with(period: :week).and_return average_baseload_last_week_kw

        allow_any_instance_of(Schools::Advice::BaseloadService).to receive(:previous_period_average_baseload_kw).with(period: :year).and_return previous_year_average_baseload_kw
        allow_any_instance_of(Schools::Advice::BaseloadService).to receive(:previous_period_average_baseload_kw).with(period: :week).and_return previous_week_average_baseload_kw
        allow_any_instance_of(Schools::Advice::BaseloadService).to receive(:saving_through_1_kw_reduction_in_baseload) {
                                                                     OpenStruct.new(kwh: 8800, £: 1300, co2: 1600,
                                                                                    percent: nil)
                                                                   }

        # comparison
        allow_any_instance_of(Schools::Advice::BaseloadService).to receive(:benchmark_baseload).and_return comparison
        visit insights_school_advice_baseload_path(school)
      end

      it_behaves_like 'an advice page tab', tab: 'Insights'

      it 'shows the definition of baseload' do
        expect(page).to have_content('Electricity baseload is the electricity needed to provide power to appliances')
      end

      it 'shows the current baseload section' do
        expect(page).to have_content('Your current baseload')
        # check within table
        within '#current-baseload' do
          expect(page).to have_content('2.1')
          expect(page).to have_content('2.2')
        end
      end

      context 'with no recent data' do
        let(:start_date)  { Time.zone.today - 24.months }
        let(:end_date)    { Time.zone.today - 2.months }

        before do
          visit insights_school_advice_baseload_path(school)
        end

        it 'shows different message' do
          # weekly baseload
          within '#current-baseload' do
            expect(page).to have_no_content('2.2')
            expect(page).to have_content('no recent data')
          end
        end

        it_behaves_like 'an advice page showing electricity data warning'
      end

      context 'with less than a years data' do
        let(:start_date) { Time.zone.today - 14.days }

        it 'shows different message' do
          visit insights_school_advice_baseload_path(school)
          within '#current-baseload' do
            expect(page).to have_content("#{start_date.to_fs(:es_short)} - #{end_date.to_fs(:es_short)}")
          end
        end
      end

      it 'shows the comparison section' do
        expect(page).to have_content('How do you compare?')
        within '.school-comparison-component .footer-row' do
          expect(page).to have_content('1.1')
          expect(page).to have_content('2.4')
        end
        # check within comparison component
        within '.school-comparison-component .callout-box' do
          expect(page).to have_content('2.1')
        end
        expect(page).to have_content('compare with other schools in your group')
      end

      it 'shows the how have we analysed your data modal' do
        # expect(page).to have_content("How did we calculate these figures?")
        click_on 'How did we calculate these figures?'
        expect(page).to have_content('How have we analysed your data?')
        expect(page).to have_content('School characteristics')
        expect(page).to have_content('Cost calculations')
        expect(page).to have_content('Your electricity tariffs have changed in the last year, the last change was on 01 Sep 2022, before this date the average tariff was 15p/kWh, and since it is £3.10/kWh. This will increase your electricity costs by 1,900&percnt; going forwards')
        expect(page).to have_content('School comparisons')
        expect(page).to have_content('"Exemplar" schools represent the top 17.5% of Energy Sparks schools')
      end
    end
  end
end
