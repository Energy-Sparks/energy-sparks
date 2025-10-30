require 'rails_helper'

describe 'School group heating control page' do
  let!(:school_group) { create(:school_group, :with_active_schools, public: true) }
  let!(:school) { create(:school, :with_fuel_configuration, school_group: school_group) }
  let!(:report) { create(:report, key: :heating_in_warm_weather) }
  let(:advice_page_key) { :heating_control }

  let(:variables) do
    {
      percent_of_annual_heating: 0.11390515585484336,
      warm_weather_heating_days_all_days_kwh: 4648.785189592818,
      warm_weather_heating_days_all_days_co2: 976.2448898144918,
      warm_weather_heating_days_all_days_gbpcurrent: 139.46355568778452,
      warm_weather_heating_days_all_days_days: 150.0,
      average_one_year_saving_gbp: 200.0,
      one_year_saving_kwh: 100.0,
      one_year_saving_co2: 300.0
    }
  end

  before do
    advice_page = create(:advice_page, key: advice_page_key)

    alert_run = create(:alert_generation_run, school: school)

    alert_type = create(:alert_type, class_name: 'AlertSeasonalHeatingSchoolDays')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)

    additional_data_alert = create(:alert_type, class_name: 'AlertAdditionalPrioritisationData')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: additional_data_alert, variables: {})

    create(:advice_page_school_benchmark, school: school, advice_page: advice_page, benchmarked_as: :benchmark_school)
    Comparison::HeatingInWarmWeather.refresh
  end

  context 'when on the insights page' do
    it_behaves_like 'an access controlled group page' do
      let(:path) { insights_school_group_advice_heating_control_path(school_group) }
    end

    context 'when not signed in' do
      before do
        visit insights_school_group_advice_heating_control_path(school_group)
      end

      it_behaves_like 'a school group advice page', index: false do
        let(:breadcrumb) { I18n.t("advice_pages.#{advice_page_key}.page_title") }
        let(:title) { I18n.t('school_groups.advice_pages.heating_control.page_title') }
      end

      it 'has the comparisons section' do
        expect(page).to have_content(I18n.t('advice_pages.heating_control.insights.comparison.title'))
        expect(page).to have_css('.school-group-comparison-component')
        expect(page).to have_link(href: analysis_school_group_advice_heating_control_path(school_group))
      end

      it 'has the current use section' do
        expect(page).to have_content(I18n.t('school_groups.advice_pages.heating_control.insights.current_use.title'))
        expect(page).to have_css("##{report.key}-table")
        within("##{report.key}-table") do
          expect(page).to have_content(school.name)
        end
      end
    end
  end

  context 'when on the analysis page' do
    it_behaves_like 'an access controlled group page' do
      let(:path) { analysis_school_group_advice_heating_control_path(school_group) }
    end

    context 'when not signed in' do
      before do
        visit analysis_school_group_advice_heating_control_path(school_group)
      end

      it_behaves_like 'a school group advice page', index: false do
        let(:breadcrumb) { I18n.t("advice_pages.#{advice_page_key}.page_title") }
        let(:title) { I18n.t('school_groups.advice_pages.heating_control.page_title') }
      end

      context 'with potential savings' do
        it { expect(page).to have_content(I18n.t('school_groups.advice_pages.heating_control.analysis.potential_savings.title')) }

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
        it { expect(page).to have_content(I18n.t('school_groups.advice_pages.heating_control.analysis.comparisons.title')) }

        it_behaves_like 'a school comparison report with a table', visit: false do
          let(:expected_report) { report }
          let(:expected_school) { school }
          let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
          let(:headers) do
            ['School',
             'Percentage of annual heating consumed in warm weather',
             'Saving through turning heating off in warm weather (kWh)',
             'Saving CO2 kg',
             'Saving £',
             'Number of days heating on in warm weather']
          end
          let(:expected_table) do
            [headers, [school.name, '11.4&percnt;', '4,650', '976', '£139', '150 days']]
          end
          let(:expected_csv) do
            [headers, [school.name, '11.4', '4,650', '976', '139', '150']]
          end
        end
      end
    end
  end
end
