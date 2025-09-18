require 'rails_helper'

describe 'School group charts page' do
  let!(:school_group) { create(:school_group, public: true) }
  let!(:school) do
    school = create(:school,
                    :with_fuel_configuration,
                    :with_meter_dates,
                    school_group: school_group,
                    has_gas: false, has_storage_heaters: false, has_solar_pv: false,
                    reading_start_date: 1.year.ago,
                    number_of_pupils: 1)
    create(:energy_tariff, :with_flat_price, tariff_holder: school, start_date: nil, end_date: nil)
    create(:electricity_meter_with_validated_reading_dates,
           school:, start_date: 1.year.ago, end_date: Time.zone.today, reading: 0.5)
    school
  end

  let!(:gas_school) do
    weather_station = create(:weather_station,
                             :with_readings,
                             reading_start_date: 1.year.ago.to_date,
                             reading_end_date: Time.zone.today)
    school = create(:school,
                    :with_fuel_configuration,
                    :with_meter_dates,
                    school_group: school_group,
                    has_electricity: false, has_storage_heaters: false, has_solar_pv: false,
                    reading_start_date: 1.year.ago,
                    weather_station: weather_station,
                    number_of_pupils: 1)
    create(:energy_tariff, :with_flat_price, tariff_holder: school, start_date: nil, end_date: nil)
    create(:gas_meter_with_validated_reading_dates,
           school:, start_date: 1.year.ago, end_date: Time.zone.today, reading: 0.5)
    school
  end

  before do
    create(:advice_page, key: :electricity_long_term)
    create(:advice_page, key: :electricity_meter_breakdown)
    create(:advice_page, key: :gas_long_term)
    create(:advice_page, key: :gas_out_of_hours)
  end

  it_behaves_like 'an access controlled group advice page' do
    let(:path) { charts_school_group_advice_path(school_group) }
  end

  # following has intermittent failures due to JS errors when run as whole group. But these are unrelated to
  # the chart behaviour. So ignore errors for now and check whether the js has actually run by looking at page state
  context 'when not signed in', :js do
    context 'with no parameters' do
      before { visit charts_school_group_advice_path(school_group) }

      it_behaves_like 'a school group advice page' do
        let(:breadcrumb) { I18n.t('school_groups.titles.charts') }
        let(:title) { I18n.t('school_groups.advice.charts.title') }
      end

      context 'when checking chart state' do
        it 'has correct default chart' do
          expect(page).to have_select('chart-selection-chart-type', selected: 'Electricity use by week')
        end

        it 'has correct default title' do
          expect(page).to have_content(
            I18n.t('school_groups.advice.chart_types.electricity.management_dashboard_group_by_week_electricity.title')
          )
        end

        it 'has correct default school' do
          expect(page).to have_select('chart-selection-school-id', selected: school.name)
        end

        it 'has correct default link' do
          expect(page).to have_link(
            I18n.t('components.selectable_school_charts_component.chart_selection_dynamic_footer.link'),
            href: school_advice_electricity_long_term_path(school)
          )
        end
      end

      context 'when changing chart', :errors_expected do
        before { select 'Electricity use by meter', from: 'Choose chart' }

        it 'has updated the title' do
          expect(page).to have_content(
            I18n.t('school_groups.advice.chart_types.electricity.group_by_week_electricity_meter_breakdown_one_year.title')
          )
        end

        it 'has updated the link' do
          expect(page).to have_link(
            I18n.t('components.selectable_school_charts_component.chart_selection_dynamic_footer.link'),
            href: school_advice_electricity_meter_breakdown_path(school)
          )
        end
      end

      context 'when changing fuel type', :errors_expected do
        before { choose 'Gas', allow_label_click: true }

        it 'updates the selected school' do
          expect(page).to have_select('chart-selection-school-id', selected: gas_school.name)
        end

        it 'updates the selected chart' do
          expect(page).to have_select('chart-selection-chart-type', selected: 'Gas use by week')
        end

        it 'has updated the title' do
          expect(page).to have_content(
            I18n.t('school_groups.advice.chart_types.gas.management_dashboard_group_by_week_gas.title')
          )
        end

        it 'has updated the link' do
          expect(page).to have_link(
            I18n.t('components.selectable_school_charts_component.chart_selection_dynamic_footer.link'),
            href: school_advice_gas_long_term_path(gas_school)
          )
        end
      end
    end

    context 'with parameters' do
      before do
        visit charts_school_group_advice_path(school_group, {
        school: gas_school.slug,
        fuel_type: :gas,
        chart_type: :gas_by_day_of_week_tolerant
      })
      end

      it 'uses the defaults school' do
        expect(page).to have_select('chart-selection-school-id', selected: gas_school.name)
      end

      it 'updates the selected chart' do
        expect(page).to have_select('chart-selection-chart-type', selected: 'Out of hours gas use by day of week')
      end

      it 'has updated the title' do
        expect(page).to have_content(
          I18n.t('school_groups.advice.chart_types.gas.gas_by_day_of_week_tolerant.title')
        )
      end

      it 'has updated the link' do
        expect(page).to have_link(
          I18n.t('components.selectable_school_charts_component.chart_selection_dynamic_footer.link'),
          href: school_advice_gas_out_of_hours_path(gas_school)
        )
      end
    end
  end
end
