require 'rails_helper'

RSpec.describe "advice page", type: :system do

  let(:school) { create(:school) }
  let(:key) { 'baseload' }
  let(:learn_more) { 'here is some more explanation' }

  let!(:advice_page_baseload) { create(:advice_page, key: key, restricted: false, learn_more: learn_more) }

  context 'as non-logged in user' do

    before do
      visit school_advice_path(school)
    end

    it 'shows the advice pages index' do
      expect(page).to have_content('Advice Pages')
      expect(page).to have_link(key)
    end

    it 'shows the advice page' do
      click_on key
      expect(page).to have_content("#{key.humanize} analysis and advice")
    end

    context 'when page is restricted' do
      before do
        advice_page_baseload.update(restricted: true)
      end
      it 'does not show the restricted advice page' do
        click_on key
        expect(page).to have_content('Advice Pages')
        expect(page).to have_content("Only an admin or staff user for this school can access this content")
      end
    end
  end

  context 'as admin' do

    let(:admin) { create(:admin) }

    before do
      sign_in(admin)
      visit school_advice_path(school)
    end

    it 'shows the advice pages index' do
      expect(page).to have_content('Advice Pages')
      expect(page).to have_link(key)
    end

    it 'shows the advice page' do
      click_on key
      expect(page).to have_content("#{key.humanize} analysis and advice")
    end

    it 'shows the nav bar' do
      click_on key
      within '.advice-page-nav' do
        expect(page).to have_content("Menu")
      end
    end

    it 'shows tabs for insights, analysis, learn more' do
      click_on key
      within '.advice-page-tabs' do
        expect(page).to have_link('Insights')
        expect(page).to have_link('Analysis')
        expect(page).to have_link('Learn More')
      end
    end

    it 'shows breadcrumb' do
      click_on key
      within '.advice-page-breadcrumb' do
        expect(page).to have_link('Schools')
        expect(page).to have_link(school.name)
        expect(page).to have_link('Advice')
        expect(page).to have_text(key.humanize)
      end
    end

    it 'shows learn more content' do
      click_on key
      click_on 'Learn More'
      within '.advice-page-tabs' do
        expect(page).to have_content(learn_more)
      end
    end

    context 'when showing analysis' do

      let(:start_date)    { Date.new(2019,12,31)}
      let(:end_date)    { Date.new(2020,12,31)}
      let(:amr_data)    { double('amr-data') }

      let(:electricity_aggregate_meter)   { double('electricity-aggregated-meter')}
      let(:meter_collection)        { double('meter-collection', electricity_meters: []) }

      it 'shows analysis content' do
        allow(amr_data).to receive(:start_date).and_return(start_date)
        allow(amr_data).to receive(:end_date).and_return(end_date)
        allow(electricity_aggregate_meter).to receive(:amr_data).and_return(amr_data)
        allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(electricity_aggregate_meter)

        allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(meter_collection)

        annual_baseload_usage = double(kwh: 123.0, £: 1.0, co2: 1.0)
        baseload_usage = double(kwh: 1.0, £: 1.0, co2: 1.0)
        estimated_savings = double(kwh: 1.0, £: 1.0, co2: 1.0)

        baseload_calculation_service = double(annual_baseload_usage: annual_baseload_usage)
        allow(Baseload::BaseloadCalculationService).to receive(:new).and_return(baseload_calculation_service)

        benchmark_calculation_service = double(baseload_usage: baseload_usage, estimated_savings: estimated_savings)
        allow(Baseload::BaseloadBenchmarkingService).to receive(:new).and_return(benchmark_calculation_service)

        meter_breakdown = double(meters: ['123'], baseload_kw: 1, baseload_cost_£: 2, percentage_baseload: 3, total_baseload_kw: 4)
        baseload_breakdown_service = double(calculate_breakdown: meter_breakdown)
        allow(Baseload::BaseloadMeterBreakdownService).to receive(:new).and_return(baseload_breakdown_service)

        seasonal_variation = double(winter_kw: 1, summer_kw: 2, percentage: 3)
        estimated_costs = double(£: 1, co2: 2)
        seasonal_baseload_service = double(seasonal_variation: seasonal_variation, estimated_costs: estimated_costs)
        allow(Baseload::SeasonalBaseloadService).to receive(:new).and_return(seasonal_baseload_service)

        intraweek_variation = double(max_day_kw: 1, min_day_kw: 2, percent_intraday_variation: 3, week_saving_kwh: 4)
        intraweek_baseload_service = double(intraweek_variation: intraweek_variation)
        allow(Baseload::IntraweekBaseloadService).to receive(:new).and_return(intraweek_baseload_service)

        click_on key
        click_on 'Analysis'
        within '.advice-page-tabs' do
          expect(page).to have_content('Recent trend')
          expect(page).to have_content('baseload over the last 12 months was 123 kW')
        end
      end
    end

    context 'when page is restricted' do
      before do
        advice_page_baseload.update(restricted: true)
      end
      it 'shows the restricted advice page' do
        click_on key
        expect(page).to have_content("#{key.humanize} analysis and advice")
      end
    end
  end
end
