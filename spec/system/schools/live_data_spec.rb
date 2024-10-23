require 'rails_helper'

RSpec.describe 'live data', type: :system do
  let!(:school)             { create(:school) }
  let!(:school_admin)       { create(:school_admin, school: school) }

  let(:aggregate_school)    { double(:aggregate_school) }

  before do
    allow_any_instance_of(AggregateSchoolService).to receive(:aggregate_school).and_return(aggregate_school)
  end

  context 'with feature disabled' do
    before do
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(false)
      sign_in(school_admin)
      visit school_live_data_path(school)
    end

    it 'does not let me view live data' do
      expect(page).to have_content(school.name)
      expect(page).not_to have_content('live data')
    end
  end

  context 'with feature enabled and active cad' do
    let!(:cad) { create(:cad, active: true, school: school) }

    let!(:activity_category)  { create(:activity_category, live_data: true) }
    let!(:activity_type)      { create(:activity_type, name: 'save gas', activity_category: activity_category) }

    before do
      allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
      allow(Cads::RealtimePowerConsumptionService).to receive(:cache_power_consumption_service)
    end

    context 'when not logged in' do
      it 'returns json data payload' do
        allow_any_instance_of(Cads::LiveDataService).to receive(:read).and_return(123)
        allow(Cads::RealtimePowerConsumptionService).to receive(:read_consumption).and_return(150)

        visit school_cad_live_data_path(school, school.cads.last, format: :json)
        data = JSON.parse(page.html)

        expect(data['type']).to eq('electricity')
        expect(data['units']).to eq('watts')
        expect(data['value']).to eq(123)
        expect(data['power']).to be(150)
      end
    end

    context 'when logged in' do
      before do
        sign_in(school_admin)
        visit school_path(school)
        click_link 'Live energy data'
      end

      it 'lets me view live data' do
        expect(page).to have_content('Your live electricity data')
        expect(page).to have_content('Understanding your energy consumption')
      end

      it 'has help page' do
        create(:help_page, title: 'Live data', feature: :live_data, published: true)
        refresh
        expect(page).to have_link('Help')
      end

      it 'has links to suggestions actions etc' do
        expect(page).to have_content('Work with the pupils')
        expect(page).to have_content('Take action around the school')
        expect(page).to have_content('Explore your data')
        expect(page).to have_link('Choose another activity', href: activity_category_path(activity_category))
        expect(page).to have_link('Record an energy saving action')
        expect(page).to have_link('View pupil dashboard')
      end

      it 'has links to suggestions from live data category' do
        expect(page).to have_link('save gas')
      end

      it 'links from pupil analysis page' do
        visit pupils_school_analysis_path(school)
        within '#live-data-link' do
          expect(page).to have_content('Live energy data')
          click_link 'Live energy data'
        end
        expect(page).to have_content('Your live electricity data')
      end

      it 'returns html with reading' do
        allow_any_instance_of(Cads::LiveDataService).to receive(:read).and_raise(DataFeeds::GeoApi::NotAuthorised.new('api is broken'))

        visit school_cad_live_data_path(school, school.cads.last)

        expect(page).to have_content('Live')
        expect(page).to have_content('api is broken')
      end

      it 'returns html with error' do
        allow_any_instance_of(Cads::LiveDataService).to receive(:read).and_return(123)

        visit school_cad_live_data_path(school, school.cads.last)

        expect(page).to have_content('Live')
        expect(page).to have_content('123')
      end

      it 'returns json data payload' do
        allow_any_instance_of(Cads::LiveDataService).to receive(:read).and_return(123)
        allow(Cads::RealtimePowerConsumptionService).to receive(:read_consumption).and_return(150)

        visit school_cad_live_data_path(school, school.cads.last, format: :json)
        data = JSON.parse(page.html)

        expect(data['type']).to eq('electricity')
        expect(data['units']).to eq('watts')
        expect(data['value']).to eq(123)
        expect(data['power']).to be(150)
      end

      it 'returns json error' do
        allow_any_instance_of(Cads::LiveDataService).to receive(:read).and_raise(DataFeeds::GeoApi::NotAuthorised.new('api is broken'))

        visit school_cad_live_data_path(school, school.cads.last, format: :json)

        expect(page.status_code).to be 500
        expect(page.body).to eql('api is broken')
      end
    end
  end
end
