require 'rails_helper'

RSpec.shared_examples_for 'a group long term advice page' do
  let!(:school_group) { create(:school_group, :with_active_schools, public: true) }
  let!(:school) { create(:school, :with_fuel_configuration, school_group: school_group) }
  let!(:report) { create(:report, key: report_key) }
  let(:comparison_variables) do
    {
      "previous_year_#{fuel_type}_kwh": 1000.0,
      "current_year_#{fuel_type}_kwh": 500.0,
      "previous_year_#{fuel_type}_co2": 800.0,
      "current_year_#{fuel_type}_co2": 400.0,
      "previous_year_#{fuel_type}_gbp": 2000.0,
      "current_year_#{fuel_type}_gbp": 1200.0,
      solar_type: 'synthetic'
    }
  end
  let(:variables) do
    {
      average_one_year_saving_gbp: 200.0,
      one_year_saving_kwh: 100.0,
      one_year_saving_co2: 300.0
    }
  end

  before do
    create(:advice_page_school_benchmark,
            school: school,
            advice_page: advice_page,
            benchmarked_as: :benchmark_school)

    alert_run = create(:alert_generation_run, school: school)

    comparison_alert_type = create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: comparison_alert_type,
                   variables: comparison_variables)

    alert_type = create(:alert_type, class_name: class_name)
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type,
                   variables: variables)

    report_class.refresh
  end

  context 'when following nav link' do
    it 'redirects correctly' do
      visit school_group_advice_path(school_group)
      within('#group-advice-page-nav') do
        within("##{advice_page.fuel_type}") do
          click_on(I18n.t("advice_pages.nav.pages.#{advice_page.key}"))
        end
      end
      expect(page).to have_current_path(polymorphic_path([:insights, school_group, :advice, advice_page.key.to_sym]))
    end
  end

  context 'when on the insights page' do
    it_behaves_like 'an access controlled group advice page' do
      let(:path) { insights_path }
    end

    context 'when not signed in' do
      before do
        visit insights_path
      end

      it_behaves_like 'a school group advice page', index: false do
        let(:breadcrumb) { I18n.t("advice_pages.#{advice_page.key}.page_title") }
        let(:title) { I18n.t('school_groups.advice_pages.long_term.page_title', fuel_type: fuel_type) }
      end

      it 'has the comparisons section' do
        expect(page).to have_content(I18n.t("advice_pages.#{advice_page.key}.insights.comparison.title"))
        expect(page).to have_css('.school-group-comparison-component')
        expect(page).to have_link(href: analysis_path)
      end

      it 'has the current use section' do
        expect(page).to have_content(I18n.t('school_groups.advice_pages.long_term.insights.current_use.title'))
        expect(page).to have_css("##{report_key}-table")
        within("##{report_key}-table") do
          expect(page).to have_content(school.name)
        end
      end
    end
  end

  context 'when on the analysis page' do
    it_behaves_like 'an access controlled group advice page' do
      let(:path) { analysis_path }
    end

    context 'when not signed in' do
      before do
        visit analysis_path
      end

      it_behaves_like 'a school group advice page', index: false do
        let(:breadcrumb) { I18n.t("advice_pages.#{advice_page.key}.page_title") }
        let(:title) { I18n.t('school_groups.advice_pages.long_term.page_title', fuel_type: fuel_type) }
      end

      context 'with potential savings' do
        it { expect(page).to have_content(I18n.t('school_groups.advice_pages.long_term.analysis.potential_savings.title')) }

        it_behaves_like 'it contains the expected data table' do
          let(:table_id) { "##{advice_page.key}-savings" }
          let(:expected_header) do
            [
              ['', 'Potential savings', ''],
              ['School', 'Category', 'Energy (kWh)', 'Cost (£)', 'CO2 (kg)', '']
            ]
          end
          let(:expected_rows) do
            [
              [school.name, 'Well managed', '100', '£200', '300', 'View analysis']
            ]
          end
        end
      end

      context 'with comparison section' do
        it { expect(page).to have_content(I18n.t('school_groups.advice_pages.long_term.analysis.comparisons.title')) }

        it_behaves_like 'a school comparison report with a table', visit: false do
          let(:expected_report) { report }
          let(:expected_school) { school }
          let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page.key.to_sym]) }
          let(:headers) { comparison_table_headers }
          let(:expected_table) { comparison_table }
          let(:expected_csv) { comparison_csv }
        end
      end
    end
  end
end

describe 'School group long term advice pages' do
  context 'with electricity page' do
    it_behaves_like 'a group long term advice page' do
      let(:fuel_type) { :electricity }
      let(:report_key) { :change_in_electricity_since_last_year }
      let!(:advice_page) { create(:advice_page, key: :electricity_long_term, fuel_type: fuel_type) }
      let(:class_name) { 'AlertElectricityAnnualVersusBenchmark' }
      let(:report_class) { Comparison::ChangeInElectricitySinceLastYear }
      let(:insights_path) { insights_school_group_advice_electricity_long_term_path(school_group) }
      let(:analysis_path) { analysis_school_group_advice_electricity_long_term_path(school_group) }
      let(:comparison_table_headers) do
        ['School', 'Previous year', 'Last year', 'Change %', 'Previous year', 'Last year', 'Change %', 'Previous year',
         'Last year', 'Change %', 'Estimated']
      end
      let(:comparison_table) do
        [
          ['', 'kWh', 'CO2 (kg)', '£', 'Solar self consumption'],
          comparison_table_headers,
          [school.name, '1,000', '500', '-50&percnt;', '800', '400', '-50&percnt;', '£2,000', '£1,200', '-40&percnt;',
           'Yes'],
          ["Notes\nIn school comparisons 'last year' is defined as this year to date."]
        ]
      end
      let(:comparison_csv) do
        [
          ['', 'kWh', '', '', 'CO2 (kg)', '', '', '£', '', '', 'Solar self consumption'],
          headers,
          [school.name, '1,000', '500', '-50', '800', '400', '-50', '2,000', '1,200', '-40', 'Yes']
        ]
      end
    end
  end

  context 'with gas page' do
    it_behaves_like 'a group long term advice page' do
      let(:fuel_type) { :gas }
      let(:report_key) { :change_in_gas_since_last_year }
      let!(:advice_page) { create(:advice_page, key: :gas_long_term, fuel_type: fuel_type) }
      let(:class_name) { 'AlertGasAnnualVersusBenchmark' }
      let(:variables) do
        {
          average_one_year_saving_gbp: 200.0,
          one_year_saving_kwh: 100.0,
          one_year_saving_co2: 300.0,
          temperature_adjusted_previous_year_kwh: 1100,
          temperature_adjusted_percent: 8
        }
      end
      let(:report_class) { Comparison::ChangeInGasSinceLastYear }
      let(:insights_path) { insights_school_group_advice_gas_long_term_path(school_group) }
      let(:analysis_path) { analysis_school_group_advice_gas_long_term_path(school_group) }
      let(:comparison_table_headers) do
        ['School',
         'Previous year', 'Previous year (temperature adjusted)', 'Last year',
         'Previous year', 'Last year', 'Previous year', 'Last year',
         'Unadjusted change (kWh)', 'Temperature adjusted change (kWh)']
      end
      let(:comparison_table) do
        [['', 'kWh', 'CO2 (kg)', '£', 'Percent changed'],
         headers,
         [school.name, '1,000', '1,100', '500', '800', '400', '£2,000', '£1,200', '-50&percnt;', '+800&percnt;'],
         ["Notes\nIn school comparisons 'last year' is defined as this year to date, 'previous year' is defined as the " \
          'year before.']]
      end
      let(:comparison_csv) do
        [
          ['', 'kWh', '', '', 'CO2 (kg)', '', '£', '', 'Percent changed', ''],
          headers,
          [school.name, '1,000', '1,100', '500', '800', '400', '2,000', '1,200', '-50', '8']
        ]
      end
    end
  end
end
