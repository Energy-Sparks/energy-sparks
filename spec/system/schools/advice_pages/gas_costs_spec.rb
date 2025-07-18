require 'rails_helper'

RSpec.describe 'gas costs advice page', type: :system do
  let(:key) { 'gas_costs' }
  let(:expected_page_title) { 'Gas cost analysis' }

  include_context 'gas advice page'

  it_behaves_like 'it responds to HEAD requests'

  context 'as school admin' do
    let(:user) { create(:school_admin, school: school) }

    let(:complete_tariff_coverage) { false }
    let(:multiple_meters) { false }
    let(:period_start) { Time.zone.today.beginning_of_year }
    let(:periods_with_missing_tariffs) { [[period_start, period_start + 1.month]] }
    let(:annual_costs) { OpenStruct.new(£: 1000, days: 365) }
    let(:annual_costs_breakdown_by_meter) { {} }
    let(:beginning_of_month) { Time.zone.today.beginning_of_month }
    let(:costs_for_latest_twelve_months) do
      { beginning_of_month => Costs::MeterMonth.new(
        month_start_date: beginning_of_month,
        start_date: beginning_of_month,
        end_date: beginning_of_month.end_of_month,
        bill_component_costs: {}
      ) }
    end
    let(:change_in_costs) do
      { beginning_of_month => nil }
    end

    before do
      allow(gas_aggregate_meter).to receive(:mpan_mprn).and_return('999999')
      allow(gas_aggregate_meter).to receive(:original_meter).and_return(gas_aggregate_meter)


      allow_any_instance_of(Schools::Advice::CostsService).to receive_messages(
        complete_tariff_coverage?: complete_tariff_coverage,
        periods_with_missing_tariffs: periods_with_missing_tariffs,
        annual_costs: annual_costs,
        multiple_meters?: multiple_meters,
        annual_costs_breakdown_by_meter: annual_costs_breakdown_by_meter,
        calculate_costs_for_latest_twelve_months: costs_for_latest_twelve_months,
        calculate_change_in_costs: change_in_costs
      )

      sign_in(user)
      visit school_advice_gas_costs_path(school)
    end

    it_behaves_like 'an advice page tab', tab: 'Insights'

    context "clicking the 'Insights' tab" do
      before { click_on 'Insights' }

      it_behaves_like 'an advice page tab', tab: 'Insights'

      it 'has the intro' do
        expect(page).to have_content('Your gas bill is broken down into a variety of different charges')
      end

      it 'displays a brief summary of total cost' do
        expect(page).to have_content('We estimate your total gas cost over the last 12 months to be £1,000')
      end

      context 'and incomplete tariffs' do
        it 'displays warning about incomplete tariffs' do
          expect(page).to have_content("Energy Sparks currently doesn't have a complete record of your real tariffs")
        end
      end

      context 'and complete tariffs' do
        let(:complete_tariff_coverage) { true }

        it 'does not display warning about incomplete tariffs' do
          expect(page).not_to have_content("Energy Sparks currently doesn't have a complete record of your real tariffs")
          expect(page).to have_content('The information below provides a good estimate of your annual costs')
        end
      end
    end

    context "clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }

      it_behaves_like 'an advice page tab', tab: 'Analysis'

      context 'with single meter' do
        it 'displays a brief summary of total cost' do
          expect(page).not_to have_content(I18n.t('advice_pages.gas_costs.analysis.cost_breakdown_by_meter.title'))
          expect(page).to have_content('We estimate your total gas cost over the last 12 months to be £1,000')
        end

        context 'and incomplete tariffs' do
          it 'displays warning about incomplete tariffs' do
            expect(page).to have_content("Energy Sparks currently doesn't have a complete record of your real tariffs")
          end
        end

        context 'and complete tariffs' do
          let(:complete_tariff_coverage) { true }

          it 'does not display warning about incomplete tariffs' do
            expect(page).not_to have_content("Energy Sparks currently doesn't have a complete record of your real tariffs")
            expect(page).to have_content('The information below provides a good estimate of your annual costs')
          end
        end

        it 'with only 12 months data' do
          expect(page).to have_css('#chart_wrapper_electricity_cost_1_year_accounting_breakdown')
          expect(page).not_to have_css('#chart_wrapper_electricity_cost_comparison_last_2_years_accounting')
        end
      end

      context 'with multiple meters' do
        let(:multiple_meters) { true }

        before do
          allow_any_instance_of(Schools::Advice::CostsService).to receive_messages(
            annual_costs_breakdown_by_meter: annual_costs_breakdown_by_meter
          )
        end

        it 'does not display a brief summary of total cost' do
          expect(page).not_to have_content('We estimate your total gas cost over the last 12 months to be £1,000')
        end

        it 'displays table' do
          expect(page).to have_content('Total cost for the last 12 months')
          expect(page).to have_content('Whole school')
        end
      end
    end

    context "clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'an advice page tab', tab: 'Learn More'
    end
  end
end
