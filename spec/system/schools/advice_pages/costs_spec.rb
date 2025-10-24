# frozen_string_literal: true

require 'rails_helper'

shared_examples 'a costs advice page' do
  it_behaves_like 'it responds to HEAD requests'

  context 'with a school admin' do
    let(:complete_tariff_coverage) { false }
    let(:multiple_meters) { false }
    let(:periods_with_missing_tariffs) do
      period_start = Time.zone.today.beginning_of_year
      [[period_start, period_start + 1.month]]
    end
    let(:annual_costs_breakdown_by_meter) { {} }

    before do
      allow(aggregate_meter).to receive_messages(mpan_mprn: '999999', original_meter: aggregate_meter)

      beginning_of_month = Time.zone.today.beginning_of_month
      allow_any_instance_of(Schools::Advice::CostsService).to receive_messages(
        complete_tariff_coverage?: complete_tariff_coverage,
        periods_with_missing_tariffs: periods_with_missing_tariffs,
        annual_costs: OpenStruct.new(£: 1000, days: 365),
        multiple_meters?: multiple_meters,
        annual_costs_breakdown_by_meter: annual_costs_breakdown_by_meter,
        calculate_costs_for_latest_twelve_months: { beginning_of_month => Costs::MeterMonth.new(
          month_start_date: beginning_of_month,
          start_date: beginning_of_month,
          end_date: beginning_of_month.end_of_month,
          bill_component_costs: {}
        ) },
        calculate_change_in_costs: { beginning_of_month => nil }
      )

      sign_in(create(:school_admin, school: school))
      visit polymorphic_path([school, :advice, fuel_type, :costs])
    end

    it_behaves_like 'an advice page tab', tab: 'Insights'

    context "when clicking the 'Insights' tab" do
      before { click_on 'Insights' }

      it_behaves_like 'an advice page tab', tab: 'Insights'

      it 'has the intro' do
        expect(page).to have_content("Your #{fuel_type} bill is broken down into a variety of different charges")
      end

      it 'displays a brief summary of total cost' do
        expect(page).to have_content("We estimate your total #{fuel_type} cost over the last 12 months to be £1,000")
      end

      context 'with incomplete tariffs' do
        it 'displays warning about incomplete tariffs' do
          expect(page).to have_content("Energy Sparks currently doesn't have a complete record of your real tariffs")
        end
      end

      context 'with complete tariffs' do
        let(:complete_tariff_coverage) { true }

        it 'does not display warning about incomplete tariffs' do
          expect(page).to have_no_content("Energy Sparks currently doesn't have a complete record of your real tariffs")
          expect(page).to have_content('The information below provides a good estimate of your annual costs')
        end
      end
    end

    context "when clicking the 'Analysis' tab" do
      before { click_on 'Analysis' }

      it_behaves_like 'an advice page tab', tab: 'Analysis'

      context 'with single meter' do
        it 'displays a brief summary of total cost' do
          expect(page).to \
            have_no_content(I18n.t("advice_pages.#{fuel_type}_costs.analysis.cost_breakdown_by_meter.title"))
          expect(page).to have_content("We estimate your total #{fuel_type} cost over the last 12 months to be £1,000")
        end

        context 'with incomplete tariffs' do
          it 'displays warning about incomplete tariffs' do
            expect(page).to have_content("Energy Sparks currently doesn't have a complete record of your real tariffs")
          end
        end

        context 'with complete tariffs' do
          let(:complete_tariff_coverage) { true }

          it 'does not display warning about incomplete tariffs' do
            expect(page).to have_no_content("Energy Sparks currently doesn't have a complete record of your real tariffs")
            expect(page).to have_content('The information below provides a good estimate of your annual costs')
          end
        end

        it 'with only 12 months data' do
          expect(page).to have_css('#chart_wrapper_electricity_cost_1_year_accounting_breakdown')
          expect(page).to have_no_css('#chart_wrapper_electricity_cost_comparison_last_2_years_accounting')
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
          expect(page).to \
            have_no_content("We estimate your total #{fuel_type} cost over the last 12 months to be £1,000")
        end

        it 'displays table' do
          expect(page).to have_content('Total cost for the last 12 months')
          expect(page).to have_content('Whole school')
        end
      end
    end

    context "when clicking the 'Learn More' tab" do
      before { click_on 'Learn More' }

      it_behaves_like 'an advice page tab', tab: 'Learn More'
    end
  end
end

shared_examples 'a costs advice page with a meter costs chart endpoint' do
  include_context 'advice page'

  let(:school) do
    school = create(:school, :with_basic_configuration_single_meter_and_tariffs, fuel_type:)
    meter = school.meters.first
    create(:"#{fuel_type}_meter_with_validated_reading_dates",
           school:,
           start_date: meter.first_validated_reading,
           end_date: meter.last_validated_reading,
           reading: 1)
    school
  end

  def expect_javascript(mpan_mprn)
    visit polymorphic_path([:meter_costs, school, :advice, fuel_type, :costs], format: :js, mpan_mprn:)
    expect(page.status_code).to eq(200)
    expect(page).to have_content('processAnalysisCharts()')
  end

  context 'with the aggregate meter' do
    it 'returns javascript' do
      expect_javascript(AggregateSchoolService.new(school).aggregate_school.aggregate_meter(fuel_type).mpan_mprn)
    end
  end

  context 'with the real meter' do
    it 'returns javascript' do
      expect_javascript(school.meters.first.mpan_mprn)
    end
  end
end

RSpec.describe 'costs advice pages' do
  describe 'gas' do
    let(:key) { 'gas_costs' }

    describe 'tabs' do
      let(:expected_page_title) { 'Gas cost analysis' }

      include_context 'gas advice page'
      it_behaves_like 'a costs advice page'
    end

    describe 'meter costs chart endpoint' do
      let(:fuel_type) { :gas }

      it_behaves_like 'a costs advice page with a meter costs chart endpoint'
    end
  end

  describe 'electricity costs advice page' do
    let(:key) { 'electricity_costs' }

    describe 'tabs' do
      let(:expected_page_title) { 'Electricity cost analysis' }

      include_context 'electricity advice page'
      it_behaves_like 'a costs advice page'
    end

    describe 'meter costs chart endpoint' do
      let(:fuel_type) { :electricity }

      it_behaves_like 'a costs advice page with a meter costs chart endpoint'
    end
  end
end
