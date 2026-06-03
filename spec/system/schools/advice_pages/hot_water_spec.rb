require 'rails_helper'

RSpec.describe 'hot water advice page', type: :system do
  let(:key) { 'hot_water' }
  let(:expected_page_title) { 'Hot water usage analysis' }

  include_context 'gas advice page'

  it_behaves_like 'it responds to HEAD requests'

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }
    let(:saving_£_percent) { 0.28327380733860796 }
    let(:enough_data) { true }

    before do
      allow_any_instance_of(Schools::Advice::HotWaterController).to receive_messages(
        {
          gas_hot_water_service: OpenStruct.new(enough_data?: enough_data),
          gas_hot_water_model: OpenStruct.new(
            investment_choices: OpenStruct.new(
              existing_gas: OpenStruct.new(
                annual_co2: 14_677.565516249997,
                annual_kwh: 69_893.16912499999,
                annual_£: 2096.795073749998,
                capex: 0.0,
                efficiency: 0.3910029812945617
                            ),
              gas_better_control: OpenStruct.new(
                saving_kwh: 19_798.904124999986,
                saving_kwh_percent: 0.2832738073386079,
                saving_£: 593.9671237499992,
                saving_£_percent: saving_£_percent,
                saving_co2: 4157.769866249997,
                saving_co2_percent: 0.2832738073386079,
                payback_years: 0.0,
                annual_kwh: 50_094.265,
                annual_£: 1502.827949999999,
                annual_co2: 10_519.79565,
                capex: 0.0,
                efficiency: 0.5455402429799101
                                  ),
              point_of_use_electric: OpenStruct.new(
                saving_kwh: 36_304.981624999986,
                saving_kwh_percent: 0.5194353336600116,
                saving_£: -3009.9529537500025,
                saving_£_percent: -1.4355017290110634,
                saving_co2: 9639.337391249997,
                saving_co2_percent: 0.6567395240428654,
                payback_years: -6.511729685203551,
                annual_kwh: 33_588.1875,
                annual_£: 5106.748027500001,
                annual_co2: 5038.228125,
                capex: 19_600.0,
                efficiency: 0.813632396806169
                                     )
                                ),
            efficiency_breakdowns: OpenStruct.new(
              daily: OpenStruct.new(
                kwh: OpenStruct.new(
                  school_day_open: 256.89366666666666,
                  school_day_closed: 32.387866666666575,
                  holiday: 144.49537500000002,
                  weekend: 4.2845,
                  total: 438.06140833333325
                  ),
                £: OpenStruct.new(
                  school_day_open: 7.706809999999995,
                  school_day_closed: 0.9716359999999965,
                  holiday: 4.334861249999998,
                  weekend: 0.12853499999999993,
                  total: 13.141842249999987
                  )
                ),
              annual: OpenStruct.new(
                kwh: OpenStruct.new(
                  school_day_open: 50_094.265,
                  school_day_closed: 6315.633999999982,
                  holiday: 13_149.079125000002,
                  weekend: 334.19100000000003,
                  total: 69_893.16912499999
                  ),
                £: OpenStruct.new(
                  school_day_open: 1502.827949999999,
                  school_day_closed: 189.46901999999932,
                  holiday: 394.47237374999975,
                  weekend: 10.025729999999994,
                  total: 2096.7950737499978
                  )
                )
                                   )
          )
        }
      )

      sign_in(user)
      visit school_advice_hot_water_path(school)
    end

    it_behaves_like 'an advice page tab', tab: 'Insights'

    context 'when school has a pool' do
      before do
        allow_any_instance_of(Schools::Advice::HotWaterController).to receive_messages(
          has_swimming_pool?: true
        )
        click_on 'Insights'
      end

      it 'shows not relevant page' do
        expect(page).to have_content(I18n.t('advice_pages.hot_water.not_relevant.swimming_pool.title'))
        expect(page).to have_content('pool')
      end
    end

    context 'when efficiency is too high' do
      before do
        allow_any_instance_of(Schools::Advice::HotWaterController).to receive_messages(
          has_swimming_pool?: false,
          minimal_use_of_gas?: true
        )
        click_on 'Insights'
      end

      it 'shows not relevant page' do
        expect(page).to have_content(I18n.t('advice_pages.hot_water.not_relevant.other_reasons.title'))
      end
    end

    context 'when not enough data' do
      let(:enough_data) { false }

      before do
        click_on 'Insights'
      end

      it 'shows not enough data page' do
        expect(page).to have_content('Not enough data to run analysis')
      end
    end

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }

      it_behaves_like 'an advice page tab', tab: 'Insights'

      it 'shows expected content' do
        expect(page).to have_content('Your hot water use')
        expect(page).to have_content('How do you compare?')
        expect(page).to have_content('70,000') # 69_893  annual efficiency kwh total
        expect(page).to have_content('£2,100') # 2096    annual efficiency £ total
      end

      context 'for a investment_choices.gas_better_control.saving_£_percent under 2 percent' do
        let(:saving_£_percent) { 0.001 }

        it 'shows below table content' do
          expect(page).to have_content('Your holiday and weekend hot water use is already very low, well done.')
        end
      end

      context 'for a investment_choices.gas_better_control.saving_£_percent above 2 percent but under 10 percent' do
        let(:saving_£_percent) { 0.09 }

        it 'shows below table content' do
          expect(page).to have_content('Your holiday and weekend hot water use is already very low. You could reduce your annual gas consumption for hot water by 9&percnt; by switching it off completely outside of school hours.')
        end
      end

      context 'for a investment_choices.gas_better_control.saving_£_percent including and above 10 percent' do
        let(:saving_£_percent) { 0.10 }

        it 'shows below table content' do
          expect(page).to have_content('The table below shows that 10&percnt; of the energy used to heat your hot water is used outside of school opening times. Adjusting your boiler settings to ensure that you are only heating water when it is needed could save you £590 per year')
          expect(page).to have_content('Or you could investigate replacing your current hot water system with point of use electric heaters.')
        end
      end

      context 'for a investment_choices.gas_better_control.saving_£_percent including and above 10 percent' do
        let(:saving_£_percent) { 0.99 }

        it 'shows below table content' do
          expect(page).to have_content('The table below shows that 99&percnt; of the energy used to heat your hot water is used outside of school opening times. Adjusting your boiler settings to ensure that you are only heating water when it is needed could save you £590 per year')
          expect(page).to have_content('Or you could investigate replacing your current hot water system with point of use electric heaters.')
        end
      end
    end

    context "clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }

      it_behaves_like 'an advice page tab', tab: 'Analysis'

      it 'shows expected content' do
        expect(page).to have_content('Hot water efficiency improvement options')
        expect(page).to have_content('How does Energy Sparks calculate the efficiency and potential savings of a school’s hot water system?')
        expect(page).to have_content('£20,000') # 19,600  point_of_use_electric capex

        expect(page).to have_css('#chart_wrapper_hotwater')
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'an advice page tab', tab: 'Learn More'
    end
  end
end
