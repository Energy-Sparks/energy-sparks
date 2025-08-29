require 'rails_helper'

describe 'School group baseload page' do
  let!(:school_group) { create(:school_group, :with_active_schools, public: true) }
  let!(:school) { create(:school, :with_fuel_configuration, school_group: school_group) }
  let!(:report) { create(:report, key: :baseload_per_pupil) }

  let(:baseload_variables) do
    {
      average_baseload_last_year_kw: 20.0,
      average_baseload_last_year_gbp: 1000.0,
      one_year_baseload_per_pupil_kw: 0.002,
      annual_baseload_percent: 0.1,
      one_year_saving_versus_exemplar_gbp: 200.0,
      average_one_year_saving_gbp: 200.0,
      one_year_saving_kwh: 100.0,
      one_year_saving_co2: 300.0
    }
  end

  let(:additional_data_variables) do
    {
      electricity_economic_tariff_changed_this_year: true
    }
  end

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [tariff_changed_last_year] }
  end

  before do
    advice_page = create(:advice_page, key: :baseload)

    alert_run = create(:alert_generation_run, school: school)

    baseload_alert = create(:alert_type, class_name: 'AlertElectricityBaseloadVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: baseload_alert,
                   variables: baseload_variables)

    additional_data_alert = create(:alert_type, class_name: 'AlertAdditionalPrioritisationData')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: additional_data_alert,
                   variables: additional_data_variables)

    create(:advice_page_school_benchmark, school: school, advice_page: advice_page, benchmarked_as: :benchmark_school)
    Comparison::BaseloadPerPupil.refresh
  end

  context 'when on the insights page' do
    it_behaves_like 'an access controlled group advice page' do
      let(:path) { insights_school_group_advice_baseload_path(school_group) }
    end

    context 'when not signed in' do
      before do
        visit school_group_advice_path(school_group)
        within('.advice-page-nav') do
          click_on(I18n.t('advice_pages.nav.pages.baseload'))
        end
      end

      it_behaves_like 'a school group advice page', index: false do
        let(:breadcrumb) { I18n.t('advice_pages.baseload.page_title') }
        let(:title) { I18n.t('school_groups.advice_pages.baseload.page_title') }
      end

      it 'has the comparisons section' do
        expect(page).to have_content(I18n.t('advice_pages.baseload.comparison.title'))
        expect(page).to have_css('.school-group-comparison-component')
        expect(page).to have_link(href: analysis_school_group_advice_baseload_path(school_group, anchor: 'potential-savings'))
      end

      it 'has the key insights section' do
        expect(page).to have_content(I18n.t('school_groups.advice_pages.baseload.insights.current_baseload.title'))
        expect(page).to have_css('#baseload_per_pupil-table')
        within('#baseload_per_pupil-table') do
          expect(page).to have_content(school.name)
          expect(page).to have_content('20')
        end
      end
    end
  end

  context 'when on the analysis page' do
    it_behaves_like 'an access controlled group advice page' do
      let(:path) { analysis_school_group_advice_baseload_path(school_group) }
    end

    context 'when not signed in' do
      before do
        visit analysis_school_group_advice_baseload_path(school_group)
      end

      it_behaves_like 'a school group advice page', index: false do
        let(:breadcrumb) { I18n.t('advice_pages.baseload.page_title') }
        let(:title) { I18n.t('school_groups.advice_pages.baseload.page_title') }
      end

      context 'with potential savings' do
        it { expect(page).to have_content(I18n.t('school_groups.advice_pages.baseload.analysis.potential_savings.title')) }

        it_behaves_like 'it contains the expected data table' do
          let(:table_id) { '#baseload-savings' }
          let(:expected_header) do
            [
              ['', 'Savings', ''],
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
        it { expect(page).to have_content(I18n.t('school_groups.advice_pages.baseload.analysis.comparisons.title')) }

        it_behaves_like 'a school comparison report with a table' do
          let(:expected_report) { report }
          let(:expected_school) { school }
          let(:advice_page_path) { insights_school_advice_baseload_path(expected_school) }
          let(:headers) do
            ['School', 'Baseload per pupil (W)', 'Last year cost of baseload', 'Average baseload kW',
             'Baseload as a percent of total usage', 'Saving if matched exemplar school (using latest tariff)']
          end
          let(:expected_table) do
            [headers,
             ["#{school.name} [5]", '2', '£1,000', '20', '10&percnt;', '£200'],
             ["Notes\n" \
              '[5] The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
              "tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons " \
              "'last year' is defined as this year to date."]]
          end
          let(:expected_csv) do
            [headers, [school.name, '2', '1,000', '20', '10', '200']]
          end
        end
      end
    end
  end
end
