# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'solar pv advice page', :aggregate_failures do
  let(:key) { 'solar_pv' }

  include_context 'solar advice page'

  def expected_page_title
    school.has_solar_pv? ? 'Solar PV generation' : 'Benefits of installing solar panels'
  end

  it_behaves_like 'it responds to HEAD requests'

  context 'as school admin' do
    let(:user) { create(:school_admin, school:) }

    before do
      allow_any_instance_of(Schools::Advice::SolarPvController).to receive_messages(
        {
          create_analysable: OpenStruct.new(enough_data?: true),
          build_existing_benefits: OpenStruct.new(
            annual_saving_from_solar_pv_percent: 0.2112828204597476,
            annual_electricity_including_onsite_solar_pv_consumption_kwh: 61_057.88139174447,
            annual_carbon_saving_percent: 0.2324996269349433,
            saving_£current: 1935.0722087616766,
            export_£: 64.77266266370466,
            annual_co2_saving_kg: 2541.832811649812,
            annual_solar_pv_kwh: 14_195.934645018606,
            annual_exported_solar_pv_kwh: 1295.4532532740932,
            annual_solar_pv_consumed_onsite_kwh: 12_900.481391744512,
            annual_consumed_from_national_grid_kwh: 48_157.39999999996
          ),
          build_potential_benefits: OpenStruct.new(
            optimum_kwp: 52.5,
            optimum_payback_years: 5.682322708769174,
            optimum_mains_reduction_percent: 0.10478762755164217,
            scenarios: [OpenStruct.new(
              kwp: 1,
              panels: 3,
              area: 4,
              solar_consumed_onsite_kwh: 893.9545973935678,
              exported_kwh: 0.0,
              solar_pv_output_kwh: 893.954597393567,
              reduction_in_mains_percent: 0.002068165948887468,
              mains_savings_£: 140.1736542641811,
              solar_pv_output_co2: 169.23840876311736,
              capital_cost_£: 2392.9653,
              payback_years: 17.07143409053209
            )]
          )
        }
      )

      sign_in(user)
      visit school_advice_solar_pv_path(school)
    end

    it_behaves_like 'an advice page tab', tab: 'Insights'

    context "clicking the 'Insights' tab as a school *without* solar pv" do
      before do
        allow_any_instance_of(School).to receive(:has_solar_pv?).and_return(false)

        click_on 'Insights'
      end

      it_behaves_like 'an advice page tab', tab: 'Insights'

      it 'shows expected content' do
        expect(page).to have_content('Benefits of installing solar panels')
        expect(page).to have_no_content('Solar PV generation')

        expect(page).to have_content('What is solar PV?')
        expect(page).to have_content('Potential benefits for your school')
      end
    end

    context "clicking the 'Insights' tab as a school *with* solar pv" do
      before do
        allow_any_instance_of(School).to receive(:has_solar_pv?).and_return(true)
        click_on 'Insights'
      end

      it_behaves_like 'an advice page tab', tab: 'Insights'

      it 'shows expected content' do
        expect(page).to have_no_content('Benefits of installing solar panels')
        expect(page).to have_content('Solar PV generation')

        expect(page).to have_content('What is solar PV?')
        expect(page).to have_content('Your solar energy production')
        expect(page).to have_content('Total consumption')
        expect(page).to have_content('61,000')
        expect(page).to have_content('How do you compare?')
        expect(page).to \
          have_content("based on usage between #{start_date.to_fs(:es_short)} and #{end_date.to_fs(:es_short)}")
      end
    end

    context "clicking the 'Analysis' tab as a school *without* solar pv" do
      before do
        allow_any_instance_of(School).to receive(:has_solar_pv?).and_return(false)
        @expected_page_title = 'Benefits of installing solar panels'

        click_on 'Analysis'
      end

      it_behaves_like 'an advice page tab', tab: 'Analysis'

      it 'shows expected content' do
        expect(page).to have_content('Analysis')
        expect(page).to have_content('Installing solar PV at your school will reduce the electricity you consume')
        expect(page).to have_content('Capacity (kWp)')
        expect(page).to have_content('890')
      end
    end

    context "clicking the 'Analysis' tab as a school *with* solar pv" do
      before do
        allow_any_instance_of(School).to receive(:has_solar_pv?).and_return(true)

        click_on 'Analysis'
      end

      it_behaves_like 'an advice page tab', tab: 'Analysis'

      it 'shows expected content' do
        expect(page).to have_content('Analysis')
        expect(page).to have_content('Long term trends')
        expect(page).to have_content('Recent electricity consumption and solar production')
        expect(page).to have_content('Benefits of having installed solar panels')
        within('#investment-returns') do
          expect(page).to have_content('Before April 2019')
          expect(page).to have_content('14,000 kWh')
          expect(page).to have_content('After April 2019')
          expect(page).to have_content("#{BenchmarkMetrics.pricing.solar_export_price * 100}p per kWh")
          expect(page).to have_content('£65')
        end
        expect(page).to have_css('#chart_wrapper_solar_pv_group_by_month')
        expect(page).to have_css('#chart_wrapper_solar_pv_last_7_days_by_submeter')
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'an advice page tab', tab: 'Learn More'
    end
  end
end
