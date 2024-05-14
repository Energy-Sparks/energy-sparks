# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'electricity long term advice page', :aggregate_failures do
  let(:reading_start_date) { 1.year.ago }
  let(:school) do
    school = create(:school, :with_school_group, :with_fuel_configuration, number_of_pupils: 1)
    create(:energy_tariff, :with_flat_price, tariff_holder: school, start_date: nil, end_date: nil)
    create(:electricity_meter_with_validated_reading_dates,
           school: school, start_date: reading_start_date, end_date: Time.zone.today, reading: 0.5)
    school
  end

  before { create(:advice_page, key: :electricity_long_term) }

  shared_examples 'an electricity long term advice page tab' do |tab:|
    it_behaves_like 'an advice page tab', tab: tab do
      let(:key) { :electricity_long_term }
      let(:advice_page) { AdvicePage.find_by(key: key) }
      let(:expected_page_title) { 'Long term changes in electricity consumption' }
      # also uses "school"
    end
  end

  context 'when a school admin' do
    before do
      sign_in(create(:school_admin, school: school))
      visit school_advice_electricity_long_term_path(school)
    end

    context 'with the default tab' do
      it_behaves_like 'an electricity long term advice page tab', tab: 'Insights'
    end

    context "when on the 'Insights' tab" do
      before { click_on 'Insights' }

      context 'with 30 days of meter data' do
        let(:reading_start_date) { 30.days.ago }

        it 'includes expected sections' do
          data_available_from = reading_start_date + 89.days # TODO: not sure why this isn't 90 days
          expect(page).to have_content('Assuming we continue to regularly receive data we expect this analysis to be ' \
                                       "available after #{data_available_from.to_s(:es_short)}")
        end
      end

      context 'with 90 days of meter data' do
        let(:reading_start_date) { 90.days.ago }

        it_behaves_like 'an electricity long term advice page tab', tab: 'Insights'

        it 'includes expected sections' do
          expect(page).to have_content('Tracking long term trends')
          expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.insights.current_usage.title'))
          expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.insights.comparison.title'))
        end

        it 'includes expected data' do
          expect(find('table.advice-table')).to have_content(
            ["#{reading_start_date.to_s(:es_short)} - #{Time.zone.today.to_s(:es_short)}", '2,200', '360', '£220', '-']
            .join(' ')
          )
          expect(page).to have_content('220kWh of electricity')
        end

        it 'excludes the comparison' do
          expect(page).to have_no_css('#electricity-comparison')
        end
      end

      context 'with more than a years meter data' do
        it_behaves_like 'an electricity long term advice page tab', tab: 'Insights'

        it 'includes expected sections' do
          expect(page).to have_content('Tracking long term trends')
          expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.insights.current_usage.title'))
          expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.insights.comparison.title'))
        end

        it 'includes expected data' do
          expect(find('table.advice-table')).to have_content(['Last year', '8,700', '1,400', '£870', '-'].join(' '))
          expect(page).to have_content("Exemplar\n<190 kWh")
          expect(page).to have_content("Well managed\n<220 kWh")
        end

        it 'includes the comparison' do
          expect(page).to have_css('#electricity-comparison')
        end
      end
    end

    context "when on the 'Analysis' tab" do
      before { click_on 'Analysis' }

      context 'with more than 90 days of meter data' do
        let(:reading_start_date) { 90.days.ago }

        it_behaves_like 'an electricity long term advice page tab', tab: 'Analysis'

        it 'includes expected sections' do
          expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.analysis.recent_trend.title'))
          expect(page).to have_no_content(I18n.t('advice_pages.electricity_long_term.analysis.comparison.title'))
          expect(page).to have_no_content(I18n.t('advice_pages.electricity_long_term.analysis.meter_breakdown.title'))
        end

        it "doesn't have a notice saying usage is high" do
          expect(page).to have_no_content(I18n.t('advice_pages.electricity_long_term.analysis.comparison.assessment.high.title'))
        end

        it 'includes expected charts' do
          expect(page).to have_content(I18n.t('advice_pages.electricity_out_of_hours.analysis.holiday_usage.management_dashboard_group_by_week_electricity.title'))
          expect(page).to have_css('#chart_management_dashboard_group_by_week_electricity')

          expect(page).to have_css('#chart_wrapper_electricity_by_month_year_0_1')
          expect(page).to have_no_css('#chart_wrapper_group_by_week_electricity_versus_benchmark')
          expect(page).to have_no_css('#chart_wrapper_group_by_week_electricity_unlimited')
          expect(page).to have_no_css('#chart_wrapper_electricity_longterm_trend')
        end
      end

      context 'with more than a years meter data' do
        it_behaves_like 'an electricity long term advice page tab', tab: 'Analysis'

        it 'includes expected sections' do
          expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.analysis.recent_trend.title'))
          expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.analysis.comparison.title'))
          expect(page).to have_no_content(I18n.t('advice_pages.electricity_long_term.analysis.meter_breakdown.title'))
        end

        it 'says usage is high' do
          expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.analysis.comparison.assessment.high.title'))
        end

        it 'includes expected charts' do
          expect(page).to have_css('#chart_wrapper_group_by_week_electricity')
          expect(page).to have_css('#chart_wrapper_group_by_week_electricity_versus_benchmark')
          expect(page).to have_css('#chart_wrapper_group_by_week_electricity_unlimited')
          expect(page).to have_css('#chart_wrapper_electricity_by_month_year_0_1')
          # not enough data for this
          expect(page).to have_no_css('#chart_wrapper_electricity_longterm_trend')
        end
      end

      context 'with more than two years of meter data' do
        let(:reading_start_date) { 730.days.ago }

        it_behaves_like 'an electricity long term advice page tab', tab: 'Analysis'

        it 'includes expected sections' do
          expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.analysis.recent_trend.title'))
          expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.analysis.comparison.title'))
          expect(page).to have_no_content(I18n.t('advice_pages.electricity_long_term.analysis.meter_breakdown.title'))
        end

        it 'says usage is high' do
          expect(page).to have_content(I18n.t('advice_pages.electricity_long_term.analysis.comparison.assessment.high.title'))
        end

        it 'includes expected charts' do
          expect(page).to have_css('#chart_wrapper_group_by_week_electricity')
          expect(page).to have_css('#chart_wrapper_group_by_week_electricity_versus_benchmark')
          expect(page).to have_css('#chart_wrapper_group_by_week_electricity_unlimited')
          expect(page).to have_css('#chart_wrapper_electricity_by_month_year_0_1')
          expect(page).to have_css('#chart_wrapper_electricity_longterm_trend')
        end
      end
    end

    context "when on the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'an electricity long term advice page tab', tab: 'Learn More'
    end
  end
end
