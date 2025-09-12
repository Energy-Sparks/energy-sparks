# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'gas long term advice page', :aggregate_failures do
  let(:reading_start_date) { 1.year.ago }
  let(:school) do
    school = create(:school,
                    :with_school_group,
                    :with_fuel_configuration,
                    :with_meter_dates,
                    fuel_type: :gas,
                    reading_start_date: reading_start_date,
                    number_of_pupils: 1)
    create(:energy_tariff, :with_flat_price, tariff_holder: school, meter_type: :gas, start_date: nil, end_date: nil)
    create(:gas_meter_with_validated_reading_dates,
           school:, start_date: reading_start_date, end_date: Time.zone.today, reading: 10)
    school
  end

  before { create(:advice_page, key: :gas_long_term, fuel_type: :gas) }

  shared_examples 'a gas long term advice page tab' do |tab:|
    it_behaves_like('an advice page tab', tab:) do
      let(:key) { :gas_long_term }
      let(:advice_page) { AdvicePage.find_by(key:) }
      let(:expected_page_title) { 'Long term changes in gas consumption' }
      # also uses "school"
    end
  end

  it_behaves_like 'it responds to HEAD requests' do
    let(:advice_page) { AdvicePage.find_by_key(:gas_long_term) }
  end

  context 'when a school admin' do
    before do
      sign_in(create(:school_admin, school:))
      visit school_advice_gas_long_term_path(school)
    end

    context 'with the default tab' do
      it_behaves_like 'a gas long term advice page tab', tab: 'Insights'
    end

    context "when on the 'Insights' tab" do
      before { click_on 'Insights' }

      context 'with more than 90 days of meter data' do
        let(:reading_start_date) { 90.days.ago }

        it_behaves_like 'a gas long term advice page tab', tab: 'Insights'

        it 'includes expected sections' do
          expect(page).to have_content('Tracking long term trends')
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.insights.current_usage.title'))
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.insights.comparison.title'))
        end

        it 'includes expected data' do
          expect(find('table.advice-table')).to have_selector(
            :table_row,
            {
              'Period' => "#{reading_start_date.to_fs(:es_short)} - #{Time.zone.today.to_fs(:es_short)}",
              'Usage (kWh)' => '44,000',
              'CO2 (kg/CO2)' => '8,000',
              'Cost (£)' => '£4,400',
              'Change since previous year' => '-'
            }
          )
          expect(page).to have_content('130,000kWh of gas')
        end

        it 'excludes the comparison' do
          expect(page).to have_no_css('#gas-comparison')
        end
      end

      context 'with more than a years meter data' do
        it_behaves_like 'a gas long term advice page tab', tab: 'Insights'

        it 'includes expected sections' do
          expect(page).to have_content('Tracking long term trends')
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.insights.current_usage.title'))
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.insights.comparison.title'))
        end

        it 'includes expected data' do
          expect(find('table.advice-table')).to have_selector(:table_row, {
                                                                'Period' => 'Last year',
                                                                'Usage (kWh)' => '170,000',
                                                                'CO2 (kg/CO2)' => '32,000',
                                                                'Cost (£)' => '£17,000',
                                                                'Change since previous year' => '-'
                                                              })
          expect(page).to have_content("Exemplar\n<100,000 kWh")
          expect(page).to have_content("Well managed\n<130,000 kWh")
        end

        it 'includes the comparison' do
          expect(page).to have_css('#gas-comparison')
          expect(page).to have_link('compare with other schools in your group',
                                    href: compare_path(benchmark: :annual_heating_costs_per_floor_area,
                                                       school_group_ids: [school.school_group.id]))
        end
      end
    end

    context "when on the 'Analysis' tab" do
      before { click_on 'Analysis' }

      context 'with 90 days of meter data' do
        let(:reading_start_date) { 90.days.ago }

        it_behaves_like 'a gas long term advice page tab', tab: 'Analysis'

        it 'includes expected sections' do
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.analysis.recent_trend.title'))
          expect(page).to have_no_content(I18n.t('advice_pages.gas_long_term.analysis.comparison.title'))
          expect(page).to have_no_content(I18n.t('advice_pages.gas_long_term.analysis.meter_breakdown.title'))
        end

        it "doesn't say usage is high" do
          expect(page).to have_no_content(I18n.t('advice_pages.gas_long_term.analysis.comparison.assessment.high.title'))
        end

        it 'includes expected charts' do
          expect(page).to have_content(I18n.t('advice_pages.gas_out_of_hours.analysis.holiday_usage.management_dashboard_group_by_week_gas.title'))
          expect(page).to have_css('#chart_wrapper_management_dashboard_group_by_week_gas')
          expect(page).to have_css('#chart_wrapper_gas_by_month_year_0_1')
          expect(page).to have_no_css('#chart_wrapper_group_by_week_gas_unlimited')
          expect(page).to have_no_css('#chart_wrapper_gas_longterm_trend')
        end
      end

      context 'with more than a years meter data' do
        it_behaves_like 'a gas long term advice page tab', tab: 'Analysis'

        it 'includes expected sections' do
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.analysis.recent_trend.title'))
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.analysis.comparison.title'))
          expect(page).to have_no_content(I18n.t('advice_pages.gas_long_term.analysis.meter_breakdown.title'))
        end

        it 'says usage is high' do
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.analysis.comparison.assessment.high.title'))
        end

        it 'includes expected charts' do
          expect(page).to have_css('#chart_wrapper_group_by_week_gas')
          expect(page).to have_css('#chart_wrapper_group_by_week_gas_unlimited')
          expect(page).to have_css('#chart_wrapper_gas_by_month_acyear_0_1')
          # not enough data for these
          expect(page).to have_no_css('#chart_wrapper_gas_longterm_trend')
        end
      end

      context 'with more than two years of meter data' do
        let(:reading_start_date) { 730.days.ago }

        it_behaves_like 'a gas long term advice page tab', tab: 'Analysis'

        it 'includes expected sections' do
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.analysis.recent_trend.title'))
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.analysis.comparison.title'))
          expect(page).to have_no_content(I18n.t('advice_pages.gas_long_term.analysis.meter_breakdown.title'))
        end

        it 'says usage is high' do
          expect(page).to have_content(I18n.t('advice_pages.gas_long_term.analysis.comparison.assessment.high.title'))
        end

        it 'includes expected charts' do
          expect(page).to have_css('#chart_wrapper_group_by_week_gas')
          expect(page).to have_css('#chart_wrapper_group_by_week_gas_unlimited')
          expect(page).to have_css('#chart_wrapper_gas_by_month_acyear_0_1')
          expect(page).to have_css('#chart_wrapper_gas_longterm_trend_academic_year')
        end
      end
    end

    context "when on the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'a gas long term advice page tab', tab: 'Learn More'
    end
  end
end
