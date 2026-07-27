# frozen_string_literal: true

require 'rails_helper'

describe 'School group solar pv page' do
  let!(:school_group) { create(:school_group, :with_active_schools, public: true) }
  let!(:school) { create(:school, :with_fuel_configuration, school_group: school_group) }
  let!(:no_solar_school) { create(:school, :with_fuel_configuration, school_group: school_group) }

  let!(:current_benefit_report) { create(:report, key: :solar_generation_summary) }
  let!(:potential_benefit_report) { create(:report, key: :solar_pv_benefit_estimate) }

  let(:solar_generation_variables) do
    {
      annual_solar_pv_kwh: 2500,
      annual_solar_pv_consumed_onsite_kwh: 2000,
      annual_exported_solar_pv_kwh: 500,
      annual_mains_consumed_kwh: 1000,
      annual_electricity_kwh: 4000
    }
  end

  let(:solar_benefit_variables) do
    {
      optimum_kwp: 44.2,
      optimum_payback_years: 2.5,
      optimum_mains_reduction_percent: 0.15,
      one_year_saving_gbpcurrent: 1000
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
    Flipper.enable(:group_solar_advice_page)
    create(:advice_page, key: :solar_pv)

    alert_run = create(:alert_generation_run, school: school)

    solar_generation_alert = create(:alert_type, class_name: 'AlertSolarGeneration')
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: solar_generation_alert, variables: solar_generation_variables)

    solar_benefit_alert = create(:alert_type, class_name: 'AlertSolarPVBenefitEstimator')
    create(:alert, school: no_solar_school, alert_generation_run: alert_run,
                   alert_type: solar_benefit_alert, variables: solar_benefit_variables)

    additional_data_alert = create(:alert_type, class_name: 'AlertAdditionalPrioritisationData')
    create(:alert, school: no_solar_school, alert_generation_run: alert_run, alert_type: additional_data_alert,
                   variables: additional_data_variables)

    Comparison::SolarGenerationSummary.refresh
    Comparison::SolarPvBenefitEstimate.refresh
  end

  context 'when on the insights page' do
    it_behaves_like 'an access controlled group page' do
      let(:path) { insights_school_group_advice_solar_pv_path(school_group) }
    end

    context 'when not signed in' do
      before do
        visit school_group_advice_path(school_group)
        within('.advice-page-nav') do
          click_on(I18n.t('advice_pages.nav.pages.solar_pv'))
        end
      end

      it_behaves_like 'a school group advice page', index: false do
        let(:breadcrumb) { I18n.t('advice_pages.solar_pv.has_solar_pv.page_title') }
        let(:title) { I18n.t('school_groups.advice_pages.solar_pv.page_title') }
      end

      it 'has the current benefits section' do
        expect(page).to have_text(I18n.t('school_groups.advice_pages.solar_pv.insights.current_benefits.title'))
        expect(page).to have_css('#solar_generation_summary-table')
        within('#solar_generation_summary-table') do
          expect(page).to have_text(school.name)
          expect(page).to have_text('1,000')
        end
      end

      it 'has the potential benefits section' do
        expect(page).to have_text(I18n.t('school_groups.advice_pages.solar_pv.insights.potential_benefits.title'))
        expect(page).to have_css('#solar_pv_benefit_estimate-table')
        within('#solar_pv_benefit_estimate-table') do
          expect(page).to have_text(no_solar_school.name)
          expect(page).to have_text('15&percnt;')
        end
      end
    end
  end

  context 'when on the analysis page' do
    it_behaves_like 'an access controlled group page' do
      let(:path) { analysis_school_group_advice_solar_pv_path(school_group) }
    end

    context 'when not signed in' do
      before do
        visit analysis_school_group_advice_solar_pv_path(school_group)
      end

      it_behaves_like 'a school group advice page', index: false do
        let(:breadcrumb) { I18n.t('advice_pages.solar_pv.has_solar_pv.page_title') }
        let(:title) { I18n.t('school_groups.advice_pages.solar_pv.page_title') }
      end

      context 'with potential benefits section' do
        it {
          expect(page).to have_text(I18n.t('school_groups.advice_pages.solar_pv.analysis.potential_benefits.title'))
        }

        it_behaves_like 'a school comparison report with a table', visit: false do
          let(:expected_report) { potential_benefit_report }
          let(:expected_school) { no_solar_school }
          let(:advice_page_path) { analysis_school_advice_solar_pv_path(expected_school) }
          let(:headers) do
            [
              I18n.t('analytics.benchmarking.configuration.column_headings.school'),
              I18n.t('analytics.benchmarking.configuration.column_headings.size_kwp'),
              I18n.t('analytics.benchmarking.configuration.column_headings.payback_years'),
              I18n.t('analytics.benchmarking.configuration.column_headings.reduction_in_mains_consumption_pct'),
              I18n.t('analytics.benchmarking.configuration.column_headings.saving_optimal_panels')
            ]
          end
          let(:expected_table) do
            [
              headers,
              ["#{no_solar_school.name} [5]",
               '44.2',
               '2 years 6 months',
               '15&percnt;',
               '£1,000'],
              ["Notes\n" \
               '[5] The tariff has changed during the last year for this school. Savings are calculated using the ' \
               'latest tariff but other £ values are calculated using the relevant tariff at the time']
            ]
          end
          let(:expected_csv) do
            [
              headers,
              [no_solar_school.name,
               '44.2',
               '2.5',
               '15',
               '1,000']
            ]
          end
        end
      end

      context 'with comparison section' do
        it { expect(page).to have_text(I18n.t('school_groups.advice_pages.solar_pv.analysis.comparisons.title')) }

        it_behaves_like 'a school comparison report with a table', visit: false do
          let(:expected_report) { current_benefit_report }
          let(:expected_school) { school }
          let(:advice_page_path) { analysis_school_advice_solar_pv_path(expected_school) }
          let(:headers) do
            ['School', 'Mains consumption (kWh)', 'Generation (kWh)', 'Self consumption (kWh)', 'Export (kWh)',
             'Total onsite consumption (kWh)']
          end
          let(:expected_table) do
            [
              headers,
              [school.name,
               '1,000',
               '2,500',
               '2,000',
               '500',
               '4,000']
            ]
          end
          let(:expected_csv) do
            [
              headers,
              [school.name,
               '1,000',
               '2,500',
               '2,000',
               '500',
               '4,000']
            ]
          end
        end

        it { expect(page).to have_css('#solar_generation_summary-chart') }
      end
    end
  end
end
