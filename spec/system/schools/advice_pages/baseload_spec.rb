require 'rails_helper'

RSpec.describe "baseload advice page", type: :system do

  let(:school) { create(:school) }
  let(:key) { 'baseload' }
  let(:learn_more) { 'here is some more explanation' }

  let!(:advice_page_baseload) { create(:advice_page, key: key, restricted: false, learn_more: learn_more) }

  let(:expected_page_title) { "Baseload analysis" }

  context 'as school admin' do

    let(:user)  { create(:school_admin, school: school) }

    before do
      sign_in(user)
      visit school_advice_path(school)
    end

    it 'shows the advice pages index' do
      expect(page).to have_content('Advice Pages')
      expect(page).to have_link(key)
    end

    it 'shows the advice page' do
      click_on key
      expect(page).to have_content(expected_page_title)
    end

    it 'shows the nav bar' do
      click_on key
      within '.advice-page-nav' do
        expect(page).to have_content("Advice")
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

      let(:start_date)  { Date.new(2019,12,31)}
      let(:end_date)    { Date.new(2020,12,31)}
      let(:amr_data)    { double('amr-data') }

      let(:electricity_aggregate_meter)   { double('electricity-aggregated-meter')}
      let(:meter_collection)              { double('meter-collection', electricity_meters: []) }

      before do
        allow(amr_data).to receive(:start_date).and_return(start_date)
        allow(amr_data).to receive(:end_date).and_return(end_date)
        allow(electricity_aggregate_meter).to receive(:amr_data).and_return(amr_data)
        allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(electricity_aggregate_meter)
        allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(meter_collection)
      end

      it 'shows analysis content' do

        average_baseload_kw = 2.4
        average_baseload_kw_benchmark = 2.1

        usage = double(kwh: 123.0, £: 456.0, co2: 789.0)
        savings = double(kwh: 11.0, £: 22.0, co2: 33.0)
        annual_average_baseload = {year: 2020, baseload_usage: usage}
        baseload_meter_breakdown = {}
        seasonal_variation = double(winter_kw: 1, summer_kw: 2, percentage: 3, estimated_saving_£: 4, estimated_saving_co2: 5, variation_rating: 6)
        seasonal_variation_by_meter = {}
        intraweek_variation = double(max_day_kw: 1, min_day_kw: 2, percent_intraday_variation: 3, estimated_saving_£: 4, estimated_saving_co2: 5, variation_rating: 6)
        intraweek_variation_by_meter = {}

        allow_any_instance_of(Schools::Advice::BaseloadController).to receive(:average_baseload_kw).and_return(average_baseload_kw)
        allow_any_instance_of(Schools::Advice::BaseloadController).to receive(:average_baseload_kw_benchmark).and_return(average_baseload_kw_benchmark)

        allow_any_instance_of(Schools::Advice::BaseloadController).to receive(:baseload_usage).and_return(usage)
        allow_any_instance_of(Schools::Advice::BaseloadController).to receive(:benchmark_usage).and_return(usage)
        allow_any_instance_of(Schools::Advice::BaseloadController).to receive(:estimated_savings).and_return(savings)
        allow_any_instance_of(Schools::Advice::BaseloadController).to receive(:annual_average_baseloads).and_return([annual_average_baseload])
        allow_any_instance_of(Schools::Advice::BaseloadController).to receive(:baseload_meter_breakdown).and_return(baseload_meter_breakdown)
        allow_any_instance_of(Schools::Advice::BaseloadController).to receive(:seasonal_variation).and_return(seasonal_variation)
        allow_any_instance_of(Schools::Advice::BaseloadController).to receive(:seasonal_variation_by_meter).and_return(seasonal_variation_by_meter)
        allow_any_instance_of(Schools::Advice::BaseloadController).to receive(:intraweek_variation).and_return(intraweek_variation)
        allow_any_instance_of(Schools::Advice::BaseloadController).to receive(:intraweek_variation_by_meter).and_return(intraweek_variation_by_meter)

        click_on key
        click_on 'Analysis'
        within '.advice-page-tabs' do
          expect(page).to have_content('Recent trend')
          expect(page).to have_content('baseload over the last 12 months was 2.4 kW')
        end
      end
    end

    context 'when page is restricted' do
      before do
        advice_page_baseload.update(restricted: true)
      end
      it 'shows the restricted advice page' do
        click_on key
        expect(page).to have_content(expected_page_title)
      end
    end
  end
end
