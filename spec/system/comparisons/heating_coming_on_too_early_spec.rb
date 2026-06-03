# frozen_string_literal: true

require 'rails_helper'

describe 'heating_coming_on_too_early' do
  let!(:schools) { create_list(:school, 3) }
  let!(:report) { create(:report, key: key) }
  let!(:alerts) do
    alert_run = create(:alert_generation_run, school: schools[0])
    create(:alert, school: schools[0], alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertHeatingComingOnTooEarly'),
                   variables: {
                     avg_week_start_time: '13:00',
                     one_year_optimum_start_saving_gbpcurrent: 0.1
                   })
    create(:alert, school: schools[0], alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertOptimumStartAnalysis'),
                   variables: {
                     average_start_time_hh_mm: '13:01',
                     start_time_standard_devation: 0.2,
                     rating: 0.3,
                     regression_start_time: 0.4,
                     optimum_start_sensitivity: 0.5,
                     regression_r2: 0.6
                   })
    create(:alert, school: schools[0], alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { gas_economic_tariff_changed_this_year: true })

    alert_run = create(:alert_generation_run, school: schools[1])
    create(:alert, school: schools[1], alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertHeatingComingOnTooEarly'),
                   variables: {
                     avg_week_start_time: '13:02',
                     one_year_optimum_start_saving_gbpcurrent: 1.1
                   })
    create(:alert, school: schools[1], alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { gas_economic_tariff_changed_this_year: false })

    alert_run = create(:alert_generation_run, school: schools[2])
    create(:alert, school: schools[2], alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertOptimumStartAnalysis'),
                   variables: {
                     average_start_time_hh_mm: '13:03',
                     start_time_standard_devation: 2.1,
                     rating: 2.2,
                     regression_start_time: 2.3,
                     optimum_start_sensitivity: 2.4,
                     regression_r2: 2.5
                   })
    create(:alert, school: schools[2], alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { gas_economic_tariff_changed_this_year: false })
  end
  let(:key) { :heating_coming_on_too_early }
  let(:advice_page_key) { :heating_control }

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [tariff_changed_last_year] }
  end

  before do
    create(:advice_page, key: advice_page_key)
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with multiple tables',
                    table_titles: [I18n.t('comparisons.tables.heating_start_time'),
                                   I18n.t('comparisons.tables.optimum_start_analysis')] do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { schools[0] }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }

      let(:headers) do
        ['School',
         'Average heating start time last week',
         'Average heating start time last year',
         'Last year saving if improve to exemplar']
      end

      let(:expected_table) do
        [headers,
         ["#{schools[0].name} [5]", '13:00', '13:01', '10p'],
         [schools[1].name, '13:02', '', '£1.10'],
         [schools[2].name, '', '13:03', ''],
         ["Notes\n[5] The tariff has changed during the last year for this school. Savings are calculated using the " \
          "latest tariff but other £ values are calculated using the relevant tariff at the time\n" \
          "In school comparisons 'last year' is defined as this year to date."]]
      end

      let(:expected_csv) do
        [headers,
         [schools[0].name, '13:00', '13:01', '0.1'],
         [schools[1].name, '13:02', '', '1.1'],
         [schools[2].name, '', '13:03', '']]
      end
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:table_name) { :optimum_start_analysis }
      let(:expected_report) { report }
      let(:expected_school) { schools[0] }

      let(:headers) do
        ['School', 'Average heating start time last year', 'Standard deviation of start time - hours, last year',
         'Optimum start rating', 'Regression model optimum start time',
         'Regression model optimum start sensitivity to outside temperature', 'Regression model optimum start r2',
         'Average heating start time last week']
      end

      let(:expected_table) do
        [headers,
         [schools[0].name, '13:01', '0.2', '0.3', '0.4', '0.5', '0.6', '13:00'],
         [schools[1].name, '', '', '', '', '', '', '13:02'],
         [schools[2].name, '13:03', '2.1', '2.2', '2.3', '2.4', '2.5', '']]
      end

      let(:expected_csv) do
        expected_table
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:chart_name) { key }
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:chart_name) { :optimum_start_analysis }
      let(:expected_report) { report }
    end
  end
end
