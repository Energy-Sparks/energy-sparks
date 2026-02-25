require 'rails_helper'

RSpec.shared_examples_for 'a group out of hours advice page' do
  let!(:school_group) { create(:school_group, :with_active_schools, public: true) }
  let!(:school) { create(:school, :with_fuel_configuration, school_group: school_group) }
  let!(:report) { create(:report, key: report_key) }
  let!(:advice_page) { create(:advice_page, key: advice_page_key, fuel_type: fuel_type) }
  let(:variables) do
    {
      schoolday_open_percent: 0.2783819813845588,
      schoolday_closed_percent: 0.3712268903038169,
      holidays_percent: 0.21123782178479827,
      weekends_percent: 0.13915330652682595,
      community_percent: 0.0,
      community_gbp: 0.0,
      out_of_hours_gbp: 41_347.98790211005,
      potential_saving_gbp: 13_006.849331677073,
      average_one_year_saving_gbp: 200.0,
      one_year_saving_kwh: 100.0,
      one_year_saving_co2: 300.0
    }
  end

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [tariff_changed_last_year] }
  end

  before do
    create(:advice_page_school_benchmark,
            school: school,
            advice_page: advice_page,
            benchmarked_as: :benchmark_school)

    alert_run = create(:alert_generation_run, school: school)

    alert_type = create(:alert_type, class_name: class_name)
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type,
                   variables: variables)

    additional_alert_type = create(:alert_type, class_name: 'AlertAdditionalPrioritisationData')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: additional_alert_type,
                   variables: additional_variables)

    report_class.refresh
  end

  context 'when on the insights page' do
    it_behaves_like 'an access controlled group page' do
      let(:path) { insights_path }
    end

    context 'when not signed in' do
      before do
        visit insights_path
      end

      it_behaves_like 'a school group advice page', index: false do
        let(:breadcrumb) { I18n.t("advice_pages.#{advice_page_key}.page_title") }
        let(:title) { I18n.t("school_groups.advice_pages.#{advice_page_key}.page_title") }
      end

      it 'has the comparisons section' do
        expect(page).to have_content(I18n.t("advice_pages.#{advice_page_key}.insights.comparison.title"))
        expect(page).to have_css('.school-group-comparison-component')
        expect(page).to have_link(href: analysis_path)
      end

      it 'has the current use section' do
        expect(page).to have_content(I18n.t("school_groups.advice_pages.#{advice_page_key}.insights.current_use.title"))
        expect(page).to have_css("##{report_key}-table")
        within("##{report_key}-table") do
          expect(page).to have_content(school.name)
        end
      end
    end
  end

  context 'when on the analysis page' do
    it_behaves_like 'an access controlled group page' do
      let(:path) { analysis_path }
    end

    context 'when not signed in' do
      before do
        visit analysis_path
      end

      it_behaves_like 'a school group advice page', index: false do
        let(:breadcrumb) { I18n.t("advice_pages.#{advice_page_key}.page_title") }
        let(:title) { I18n.t("school_groups.advice_pages.#{advice_page_key}.page_title") }
      end

      context 'with potential savings' do
        it { expect(page).to have_content(I18n.t("school_groups.advice_pages.#{advice_page_key}.analysis.potential_savings.title")) }

        it_behaves_like 'it contains the expected data table' do
          let(:table_id) { "##{advice_page_key}-savings" }
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
        it { expect(page).to have_content(I18n.t("school_groups.advice_pages.#{advice_page_key}.analysis.comparisons.title")) }

        it_behaves_like 'a school comparison report with a table', visit: false do
          let(:expected_report) { report }
          let(:expected_school) { school }
          let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
          let(:headers) do
            ['School',
             'School Day Open',
             'School Day Closed',
             'Holiday',
             'Weekend',
             'Community',
             'Community usage cost',
             'Last year out of hours cost',
             'Saving if improve to exemplar (at latest tariff)']
          end
          let(:expected_table) do
            [headers,
             ["#{school.name} [5]", '27.8&percnt;', '37.1&percnt;', '21.1&percnt;', '13.9&percnt;', '0&percnt;', '0p',
              '£41,300', '£13,000'],
             ["Notes\n" \
              '[5] The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
              "tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons " \
              "'last year' is defined as this year to date."]]
          end
          let(:expected_csv) do
            [headers,
             [school.name, '27.8', '37.1', '21.1', '13.9', '0', '0', '41,300', '13,000']]
          end
        end
      end
    end
  end
end

describe 'School group out of hours pages' do
  context 'with electricity out of hours page' do
    it_behaves_like 'a group out of hours advice page' do
      let(:fuel_type) { :electricity }
      let(:report_key) { :annual_electricity_out_of_hours_use }
      let(:advice_page_key) { :electricity_out_of_hours }
      let(:class_name) { 'AlertOutOfHoursElectricityUsage' }
      let(:report_class) { Comparison::AnnualElectricityOutOfHoursUse }
      let(:additional_variables) do
        {
          electricity_economic_tariff_changed_this_year: true
        }
      end
      let(:insights_path) { insights_school_group_advice_electricity_out_of_hours_path(school_group) }
      let(:analysis_path) { analysis_school_group_advice_electricity_out_of_hours_path(school_group) }
    end
  end

  context 'with gas out of hours page' do
    it_behaves_like 'a group out of hours advice page' do
      let(:fuel_type) { :gas }
      let(:report_key) { :annual_gas_out_of_hours_use }
      let(:advice_page_key) { :gas_out_of_hours }
      let(:class_name) { 'AlertOutOfHoursGasUsage' }
      let(:report_class) { Comparison::AnnualGasOutOfHoursUse }
      let(:additional_variables) do
        {
          gas_economic_tariff_changed_this_year: true
        }
      end
      let(:insights_path) { insights_school_group_advice_gas_out_of_hours_path(school_group) }
      let(:analysis_path) { analysis_school_group_advice_gas_out_of_hours_path(school_group) }
    end
  end
end
