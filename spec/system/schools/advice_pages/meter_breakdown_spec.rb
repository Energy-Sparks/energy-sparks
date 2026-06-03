# frozen_string_literal: true

require 'rails_helper'

shared_examples 'a meter breakdown advice page tab' do |tab:|
  it_behaves_like 'an advice page tab', tab: tab do
    let(:advice_page) { AdvicePage.find_by(key: key) }
    let(:expected_page_title) { I18n.t("advice_pages.#{key}.page_title") }
  end
end

shared_examples 'the meter breakdown is not accessible' do
  let(:fuel_type) { :electricity }

  it 'does not include a navbar link' do
    visit school_advice_path(school)
    expect(page).not_to have_content(I18n.t("advice_pages.#{key}.page_title"))
  end

  it 'redirects from the page' do
    visit path
    expect(page).to have_current_path(school_advice_path(school))
  end
end

shared_examples 'the meter breakdown is not yet available' do
  before { visit path }

  it 'shows not enough data message' do
    expect(page).to have_content(I18n.t('advice_pages.not_enough_data.title'))
  end
end

shared_examples 'the monthly chart is not available' do
  before do
    visit path
    click_on 'Analysis'
  end

  it 'does not include the chart' do
    expect(page).not_to have_css("#chart_wrapper_group_by_month_#{fuel_type}_meter_breakdown")
  end
end

shared_examples 'a meter breakdown page' do
  context 'when a school admin' do
    before do
      sign_in(create(:school_admin, school: school))
      visit path
    end

    it_behaves_like 'a meter breakdown advice page tab', tab: 'Insights'

    it 'includes a meter breakdown table' do
      expect(page).to have_content('The table below covers usage between')
      expect(page).to have_css('table#meter-breakdown-summary')
      within 'table#meter-breakdown-summary' do
        meters.each do |meter|
          expect(page).to have_content(meter.mpan_mprn)
          expect(page).to have_content(meter.name)
        end
      end
    end

    context 'when on the Analysis tab' do
      before { click_on 'Analysis' }

      it_behaves_like 'a meter breakdown advice page tab', tab: 'Analysis'

      it 'includes the one year meter breakdown chart' do
        expect(page).to have_content(I18n.t("advice_pages.#{fuel_type}_long_term.charts.group_by_week_#{fuel_type}_meter_breakdown_one_year.title"))
        expect(page).to have_content(I18n.t("advice_pages.#{fuel_type}_long_term.charts.group_by_week_#{fuel_type}_meter_breakdown_one_year.subtitle"))
        expect(page).to have_content(I18n.t("advice_pages.#{fuel_type}_long_term.charts.group_by_week_#{fuel_type}_meter_breakdown_one_year.header"))
        expect(page).to have_css("#chart_wrapper_group_by_week_#{fuel_type}_meter_breakdown_one_year")
      end

      it 'includes a meter breakdown table' do
        expect(page).to have_css('table#meter-breakdown')
        within 'table#meter-breakdown' do
          meters.each do |meter|
            expect(page).to have_content(meter.mpan_mprn)
            expect(page).to have_content(meter.name)
          end
        end
      end

      it 'includes the monthly meter breakdown chart' do
        expect(page).to have_content(I18n.t("advice_pages.#{fuel_type}_meter_breakdown.charts.group_by_month_#{fuel_type}_meter_breakdown.title"))
        expect(page).to have_content(I18n.t("advice_pages.#{fuel_type}_meter_breakdown.charts.group_by_month_#{fuel_type}_meter_breakdown.subtitle"))
        expect(page).to have_css("#chart_wrapper_group_by_month_#{fuel_type}_meter_breakdown")
      end

      it 'does not include the long term trends' do
        expect(page).not_to have_css("#chart_wrapper_group_by_year_#{fuel_type}_meter_breakdown")
      end

      it 'links to additional analysis' do
        expect(page).to have_link(I18n.t('advice_pages.electricity_costs.analysis.meter_breakdown.title'))
        if fuel_type == :electricity
          expect(page).to have_link(I18n.t('advice_pages.baseload.analysis.meter_breakdown.title'))
          expect(page).to have_link(I18n.t('advice_pages.baseload.analysis.seasonal_variation.title'))
          expect(page).to have_link(I18n.t('advice_pages.baseload.analysis.weekday_variation.title'))
        end
      end
    end
  end
end

shared_examples 'a meter breakdown page with a long term trend section' do
  context 'when a school admin' do
    before do
      sign_in(create(:school_admin, school: school))
      visit path
      click_on 'Analysis'
    end

    context 'when on the Analysis tab' do
      it 'includes the long term trend chart' do
        expect(page).to have_content(I18n.t("advice_pages.#{fuel_type}_meter_breakdown.charts.group_by_year_#{fuel_type}_meter_breakdown.title"))
        expect(page).to have_content(I18n.t("advice_pages.#{fuel_type}_meter_breakdown.charts.group_by_year_#{fuel_type}_meter_breakdown.subtitle"))
        expect(page).to have_css("#chart_wrapper_group_by_year_#{fuel_type}_meter_breakdown")
      end
    end
  end
end

RSpec.describe 'meter comparison advice pages', :aggregate_failures do
  before do
    Flipper.enable :meter_breakdowns
    create(:advice_page, key: key, fuel_type: fuel_type)
  end

  let(:key) { "#{fuel_type}_meter_breakdown".to_sym }

  context 'with electricity' do
    let(:fuel_type) { :electricity }
    let(:start_date) { 90.days.ago }

    let(:school) do
      school = create(:school,
                      :with_school_group,
                      :with_fuel_configuration,
                      :with_meter_dates,
                      reading_start_date: start_date,
                      number_of_pupils: 1)
      create(:energy_tariff, :with_flat_price, tariff_holder: school, start_date: nil, end_date: nil)
      create(:electricity_meter_with_validated_reading_dates,
             school: school, start_date: start_date, end_date: Time.zone.today, reading: 0.5)
      create(:electricity_meter_with_validated_reading_dates,
             school: school, start_date: start_date, end_date: Time.zone.today, reading: 1.0)
      school
    end

    let(:meters) { school.meters.active.electricity }

    it_behaves_like 'it responds to HEAD requests' do
      let(:advice_page) { AdvicePage.find_by_key(key) }
    end

    it_behaves_like 'a meter breakdown page' do
      let(:path) { school_advice_electricity_meter_breakdown_path(school) }
    end

    context 'when school has less than a week of data' do
      let(:start_date) { 1.day.ago }

      it_behaves_like 'the meter breakdown is not yet available' do
        let(:path) { school_advice_electricity_meter_breakdown_path(school) }
      end
    end

    context 'when school has less than a month of data' do
      let(:start_date) { 21.days.ago }

      it_behaves_like 'the monthly chart is not available' do
        let(:path) { school_advice_electricity_meter_breakdown_path(school) }
      end
    end

    context 'when school has more than a year of data' do
      let(:start_date) { 1.year.ago }

      it_behaves_like 'a meter breakdown page with a long term trend section' do
        let(:path) { school_advice_electricity_meter_breakdown_path(school) }
      end
    end

    context 'when school has only a single meter' do
      let(:school) do
        school = create(:school, :with_school_group, :with_fuel_configuration, number_of_pupils: 1)
        create(:energy_tariff, :with_flat_price, tariff_holder: school, start_date: nil, end_date: nil)
        create(:electricity_meter_with_validated_reading_dates,
               school: school, start_date: 1.year.ago, end_date: Time.zone.today, reading: 0.5)
        school
      end

      it_behaves_like 'the meter breakdown is not accessible' do
        let(:path) { school_advice_electricity_meter_breakdown_path(school) }
      end
    end
  end

  context 'with gas' do
    let(:fuel_type) { :gas }
    let(:start_date) { 90.days.ago }

    let(:school) do
      school = create(:school,
                      :with_school_group,
                      :with_fuel_configuration,
                      :with_meter_dates,
                      fuel_type: :gas,
                      reading_start_date: start_date,
                      number_of_pupils: 1)
      create(:energy_tariff, :with_flat_price, meter_type: :gas, tariff_holder: school, start_date: nil, end_date: nil)
      create(:gas_meter_with_validated_reading_dates,
             school: school, start_date: start_date, end_date: Time.zone.today, reading: 0.5)
      create(:gas_meter_with_validated_reading_dates,
             school: school, start_date: start_date, end_date: Time.zone.today, reading: 1.0)
      school
    end

    let(:meters) { school.meters.active.gas }

    it_behaves_like 'it responds to HEAD requests' do
      let(:advice_page) { AdvicePage.find_by_key(key) }
    end

    it_behaves_like 'a meter breakdown page' do
      let(:path) { school_advice_gas_meter_breakdown_path(school) }
    end

    context 'when school has less than a week of data' do
      let(:start_date) { 1.day.ago }

      it_behaves_like 'the meter breakdown is not yet available' do
        let(:path) { school_advice_gas_meter_breakdown_path(school) }
      end
    end

    context 'when school has less than a month of data' do
      let(:start_date) { 21.days.ago }

      it_behaves_like 'the monthly chart is not available' do
        let(:path) { school_advice_gas_meter_breakdown_path(school) }
      end
    end

    context 'when school has more than a year of data' do
      let(:start_date) { 1.year.ago }

      it_behaves_like 'a meter breakdown page with a long term trend section' do
        let(:path) { school_advice_gas_meter_breakdown_path(school) }
      end
    end

    context 'when school has only a single meter' do
      let(:school) do
        school = create(:school, :with_school_group, :with_fuel_configuration, number_of_pupils: 1)
        create(:energy_tariff, :with_flat_price, tariff_holder: school, start_date: nil, end_date: nil)
        create(:gas_meter_with_validated_reading_dates,
               school: school, start_date: 1.year.ago, end_date: Time.zone.today, reading: 0.5)
        school
      end

      it_behaves_like 'the meter breakdown is not accessible' do
        let(:path) { school_advice_gas_meter_breakdown_path(school) }
      end
    end
  end
end
