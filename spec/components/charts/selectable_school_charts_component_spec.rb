# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Charts::SelectableSchoolChartsComponent, :include_url_helpers, type: :component do
  subject(:html) do
    render_inline(described_class.new(**params))
  end

  let(:fuel_types) do
    [:electricity, :gas, :solar_pv]
  end

  let(:schools) do
    [
      create(:school, :with_fuel_configuration, name: 'All Fuel School'),
      create(:school, :with_fuel_configuration, has_electricity: false, has_solar_pv: false, has_storage_heaters: false, name: 'Limited Fuel School')
    ]
  end

  let(:charts) do
    {
      electricity: {
        baseload: {
          label: 'Baseload',
          title: 'Historical baseload',
          subtitle: 'This chart shows the electricity baseload for {{name}} using all available data.',
          advice_page: :baseload
        },
        electricity_by_day_of_week_tolerant: {
          label: 'Electricity by day of week',
          advice_page: :electricity_out_of_hours
        }
      },
      gas: {
        management_dashboard_group_by_week_gas: {
          label: 'Group by week gas'
        },
      },
      solar_pv: {
        management_dashboard_group_by_month_solar_pv: {
          label: 'Solar generation and use by month'
        }
      }
    }
  end

  let(:params) do
    {
      fuel_types:,
      schools:,
      charts:,
      id: 'my-component',
      classes: 'extra-classes'
    }
  end

  before do
    create(:advice_page, key: :baseload)
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { 'extra-classes' }
    let(:expected_id) { 'my-component' }
  end

  it { expect(html).to have_css('div.usage-chart') }

  it 'sets the default title' do
    expect(html).to have_content(charts[:electricity][:baseload][:title])
  end

  it 'sets the default subtitle' do
    expect(html).to have_content("This chart shows the electricity baseload for #{schools.first.name} using all available data.")
  end

  it 'sets the default footer link' do
    expect(html).to have_link(I18n.t('components.selectable_school_charts_component.chart_selection_dynamic_footer.link'),
                              href: school_advice_baseload_path(schools.first))
  end

  it 'selected the default chart' do
    expect(html).to have_select('chart-selection-chart-type', selected: 'Baseload')
  end

  it 'selected the default school' do
    expect(html).to have_select('chart-selection-school-id', selected: schools.first.name)
  end

  context 'when rendering the fuel types' do
    it 'creates options for all the fuel types' do
      fuel_types.each do |fuel_type|
        expect(html).to have_css("#chart-selection-fuel-type-#{fuel_type}[data-fuel-type='#{fuel_type}']")
      end
    end

    it 'adds labels for all the fuel types' do
      fuel_types.each do |fuel_type|
        expect(html).to have_content(I18n.t("common.#{fuel_type}"))
      end
    end

    context 'when there are limited types' do
      let(:fuel_types) { [:electricity] }

      it { expect(html).not_to have_css('#chart-selection-fuel-type-gas')}
      it { expect(html).not_to have_content(I18n.t('common.gas'))}
    end
  end

  context 'when rendering the chart types' do
    it 'has visible electricity options by default' do
      expect(html).to have_css("option[value='electricity_by_day_of_week_tolerant'][data-fuel-type='electricity']")
    end

    it 'adds hidden options for other charts' do
      expect(html).to have_css("option[value='management_dashboard_group_by_week_gas'][data-fuel-type='gas']", visible: :hidden)
    end

    it 'uses the chart labels' do
      expect(html).to have_select('chart-selection-chart-type', with_options: ['Baseload', 'Group by week gas', 'Solar generation and use by month'])
    end
  end

  context 'when rendering the school options' do
    it 'has all schools with electricity visible by default' do
      expect(html).to have_css("option[value='#{schools.first.slug}'][data-fuel-type='electricity gas solar_pv storage_heaters']")
    end

    it 'has gas only schools hidden' do
      expect(html).to have_css("option[value='#{schools.last.slug}'][data-fuel-type='gas']", visible: :hidden)
    end
  end

  context 'with overridden defaults' do
    let(:params) do
      {
        fuel_types:,
        schools:,
        charts:,
        defaults: {
          school: schools.last,
          chart_type: :management_dashboard_group_by_week_gas,
          fuel_type: :gas
        }
      }
    end

    it 'selected the default chart' do
      expect(html).to have_select('chart-selection-chart-type', selected: 'Group by week gas')
    end

    it 'selected the right school' do
      expect(html).to have_select('chart-selection-school-id', selected: schools.last.name)
    end
  end
end
