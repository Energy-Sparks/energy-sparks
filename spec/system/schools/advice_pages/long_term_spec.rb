# frozen_string_literal: true

require 'rails_helper'

shared_examples 'a long term advice page' do
  let(:reading_start_date) { 1.year.ago }
  let(:school) do
    school = create(:school,
                    :with_school_group,
                    :with_fuel_configuration,
                    :with_meter_dates,
                    fuel_type:,
                    reading_start_date: reading_start_date,
                    number_of_pupils: 1)
    create(:energy_tariff, :with_flat_price, tariff_holder: school, meter_type: fuel_type,
                                             start_date: nil, end_date: nil)
    create(:"#{fuel_type}_meter_with_validated_reading_dates",
           school:, start_date: reading_start_date, end_date: Time.zone.today, reading: 10)
    school
  end
  let(:key) { :"#{fuel_type}_long_term" }

  before { create(:advice_page, key:, fuel_type:) }

  shared_examples 'a long term advice page tab' do |tab:|
    it_behaves_like('an advice page tab', tab:) do
      let(:advice_page) { AdvicePage.find_by(key:) }
      let(:expected_page_title) { "Long term changes in #{fuel_type} consumption" }
      # also uses "school" and "key"
    end
  end

  it_behaves_like 'it responds to HEAD requests' do
    let(:advice_page) { AdvicePage.find_by(key:) }
  end

  context 'when a school admin' do
    before do
      travel_to(Date.new(2024, 12, 1))
      sign_in(create(:school_admin, school:))
      visit polymorphic_path([school, :advice, fuel_type, :long_term])
    end

    context 'with the default tab' do
      it_behaves_like 'a long term advice page tab', tab: 'Insights'
    end

    context "when on the 'Insights' tab" do
      before { click_on 'Insights' }

      context 'with 30 days of meter data' do
        let(:reading_start_date) { 30.days.ago }

        it 'includes expected sections' do
          data_available_from = reading_start_date + 89.days # TODO: not sure why this isn't 90 days
          expect(page).to have_content('Assuming we continue to regularly receive data we expect this analysis to be ' \
                                       "available after #{data_available_from.to_fs(:es_short)}")
        end
      end

      context 'with more than 90 days of meter data' do
        let(:reading_start_date) { 90.days.ago }

        it_behaves_like 'a long term advice page tab', tab: 'Insights'

        it 'includes expected sections' do
          expect(page).to have_content('Tracking long term trends')
          expect(page).to have_content(I18n.t("advice_pages.#{fuel_type}_long_term.insights.current_usage.title"))
          expect(page).to have_content(I18n.t("advice_pages.#{fuel_type}_long_term.insights.comparison.title"))
        end

        it_behaves_like 'it contains the expected data table', sortable: false, aligned: 2 do
          let(:table_id) { 'table.advice-table' }
          let(:expected_header) do
            [['Period', 'Date Range', 'Usage (kWh)', 'CO2 (kg/CO2)', 'Cost (£)', 'Change since previous period']]
          end
          let(:expected_rows) do
            [['Last year', '02 Sep 2024 - 01 Dec 2024', '44,000', fuel_type == :gas ? '8,000' : '7,100', '£4,400', '-'],
             ['Last full month', '01 Nov 2024 - 30 Nov 2024', '14,000', fuel_type == :gas ? '2,600' : '2,300', '£1,400',
              '-3.2&percnt;']]
          end
        end

        it 'includes expected data' do
          if fuel_type == :gas
            expect(page).to have_content('130,000kWh of gas')
          else
            expect(page).to have_content('220kWh of electricity')
          end
        end

        it 'excludes the comparison' do
          expect(page).to have_no_css("##{fuel_type}-comparison")
        end
      end

      context 'with more than a years meter data' do
        it_behaves_like 'a long term advice page tab', tab: 'Insights'

        it 'includes expected sections' do
          expect(page).to have_content('Tracking long term trends')
          expect(page).to have_content(I18n.t("advice_pages.#{fuel_type}_long_term.insights.current_usage.title"))
          expect(page).to have_content(I18n.t("advice_pages.#{fuel_type}_long_term.insights.comparison.title"))
        end

        it_behaves_like 'it contains the expected data table', sortable: false, aligned: 2 do
          let(:table_id) { 'table.advice-table' }
          let(:expected_header) do
            [['Period', 'Date Range', 'Usage (kWh)', 'CO2 (kg/CO2)', 'Cost (£)', 'Change since previous period']]
          end
          let(:expected_rows) do
            [['Last year', '04 Dec 2023 - 01 Dec 2024', '170,000', fuel_type == :gas ? '32,000' : '28,000', '£17,000',
              '-'],
             ['Last full month', '01 Nov 2024 - 30 Nov 2024', '14,000', fuel_type == :gas ? '2,600' : '2,300', '£1,400',
              '-3.2&percnt;']]
          end
        end

        it 'includes expected data' do
          if fuel_type == :gas
            expect(page).to have_content("Exemplar\n<100,000 kWh")
            expect(page).to have_content("Well managed\n<130,000 kWh")
          else
            expect(page).to have_content("Exemplar\n<200 kWh")
            expect(page).to have_content("Well managed\n<220 kWh")
          end
        end

        it 'includes the comparison' do
          expect(page).to have_css("##{fuel_type}-comparison")
          benchmark = fuel_type == :gas ? :annual_heating_costs_per_floor_area : :annual_electricity_costs_per_pupil
          expect(page).to have_link('compare with other schools in your group',
                                    href: compare_path(benchmark:, school_group_ids: [school.school_group.id]))
        end
      end
    end

    context "when on the 'Analysis' tab" do
      before { click_on 'Analysis' }

      shared_examples 'the analysis tab' do |recent:, comparison:, high:, longterm_chart:, limited_data_charts:|
        def expect_content(should_have, content)
          should_have ? (expect(page).to have_content(content)) : (expect(page).to have_no_content(content))
        end

        it 'includes expected sections' do
          expect_content(recent, I18n.t("advice_pages.#{fuel_type}_long_term.analysis.recent_trend.title"))
          expect_content(comparison, I18n.t("advice_pages.#{fuel_type}_long_term.analysis.comparison.title"))
          expect(page).to have_no_content(I18n.t("advice_pages.#{fuel_type}_long_term.analysis.meter_breakdown.title"))
        end

        it "doesn't say usage is high" do
          expect_content(high, I18n.t("advice_pages.#{fuel_type}_long_term.analysis.comparison.assessment.high.title"))
        end

        def expect_css(should_have, content)
          should_have ? (expect(page).to have_css(content)) : (expect(page).to have_no_css(content))
        end

        it 'includes expected charts' do
          expect_content(limited_data_charts, I18n.t("advice_pages.#{fuel_type}_out_of_hours.analysis.holiday_usage." \
                                                     "management_dashboard_group_by_week_#{fuel_type}.title"))
          expect_css(limited_data_charts, "#chart_wrapper_management_dashboard_group_by_week_#{fuel_type}")
          expect_css(limited_data_charts, "#chart_wrapper_#{fuel_type}_by_month_year_0_1")
          expect_css(limited_data_charts, "#chart_wrapper_group_by_week_#{fuel_type}" \
                                          "#{:_versus_benchmark if fuel_type == :electricity}")
          expect_css(limited_data_charts, "#chart_wrapper_group_by_week_#{fuel_type}_unlimited")
          expect_css(limited_data_charts, "#chart_wrapper_#{fuel_type}_by_month_acyear_0_1")
          expect_css(longterm_chart, "#chart_wrapper_#{fuel_type}_longterm_trend_academic_year")
        end
      end

      context 'with 90 days of meter data' do
        let(:reading_start_date) { 90.days.ago }

        it_behaves_like 'a long term advice page tab', tab: 'Analysis'
        it_behaves_like 'the analysis tab', recent: true, comparison: false, high: false, longterm_chart: false,
                                            limited_data_charts: true
      end

      context 'with more than a years meter data' do
        it_behaves_like 'a long term advice page tab', tab: 'Analysis'
        it_behaves_like 'the analysis tab', recent: true, comparison: true, high: true, longterm_chart: false,
                                            limited_data_charts: false
      end

      context 'with more than two years of meter data' do
        let(:reading_start_date) { 730.days.ago }

        it_behaves_like 'a long term advice page tab', tab: 'Analysis'
        it_behaves_like 'the analysis tab', recent: true, comparison: true, high: true, longterm_chart: true,
                                            limited_data_charts: false
      end
    end

    context "when on the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'a long term advice page tab', tab: 'Learn More'
    end
  end
end

RSpec.describe 'long term advice page', :aggregate_failures do
  describe 'gas' do
    let(:fuel_type) { :gas }

    it_behaves_like 'a long term advice page'
  end

  describe 'electricity' do
    let(:fuel_type) { :electricity }

    it_behaves_like 'a long term advice page'
  end
end
