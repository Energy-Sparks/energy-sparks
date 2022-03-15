require 'rails_helper'

describe 'targets', type: :system do

  let(:admin)                     { create(:admin) }
  let(:school)                    { create_active_school(name: "Big School")}

  let!(:electricity_progress)     { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
  let!(:school_target)            { create(:school_target, school: school, electricity_progress: electricity_progress) }

  let(:fuel_electricity)          { Schools::FuelConfiguration.new(has_electricity: true) }
  let(:school_target_fuel_types)  { ["electricity"] }

  let(:months)                    { ['jan', 'feb'] }
  let(:fuel_type)                 { :electricity }

  let(:monthly_usage_kwh)         { [10,20] }
  let(:monthly_targets_kwh)       { [8,15] }
  let(:monthly_performance)       { [-0.25,0.35] }

  let(:cumulative_usage_kwh)      { [10,30] }
  let(:cumulative_targets_kwh)    { [8,25] }
  let(:cumulative_performance)    { [-0.99,0.99] }

  let(:partial_months)            { [false, true] }

  let(:progress) do
    TargetsProgress.new(
        fuel_type: fuel_type,
        months: months,
        monthly_targets_kwh: monthly_targets_kwh,
        monthly_usage_kwh: monthly_usage_kwh,
        monthly_performance: monthly_performance,
        cumulative_targets_kwh: cumulative_targets_kwh,
        cumulative_usage_kwh: cumulative_usage_kwh,
        cumulative_performance: cumulative_performance,
        cumulative_performance_versus_synthetic_last_year: cumulative_performance,
        monthly_performance_versus_synthetic_last_year: monthly_performance,
        partial_months: partial_months
    )
  end

  let(:management_data) {
    Tables::SummaryTableData.new({
        electricity: {
          :start_date => '2016-10-01',
          :end_date => '2021-11-01',
          year: { :percent_change => 0.11050 }, workweek: { :percent_change => -0.0923132131 }
        }
    })
  }

  before(:each) do
    allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
    allow_any_instance_of(Schools::ManagementTableService).to receive(:management_data).and_return(management_data)
  end

  context 'as an admin' do

    let(:fuel_electricity) { Schools::FuelConfiguration.new(has_electricity: true, has_storage_heaters: false) }

    before(:each) do
      #update here to avoid duplicating records
      school.configuration.update!(fuel_configuration: fuel_electricity, school_target_fuel_types: school_target_fuel_types)
    end

    context 'with calculated progress' do

      before(:each) do
        sign_in(admin)
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(true)
      end

      it 'redirects to electricity' do
        visit school_progress_index_path(school)
        expect(page).to have_content('Tracking progress')
      end

      it 'redirects to management dashboard if disabled' do
        school.update!(enable_targets_feature: false)
        visit school_progress_index_path(school)
        expect(page).to have_current_path(management_school_path(school))
      end

      it 'shows electricity progress' do
        visit electricity_school_progress_index_path(school)
        expect(page).to have_content('Tracking progress')
        expect(page).to have_content('jan')
        expect(page).to have_content('feb')
        expect(page).to have_content('-25%')
        expect(page).to have_content('+35%')
        expect(page).to have_content('-99%')
        expect(page).to have_content('+99%')
      end

      it 'links to help page if there is one' do
        create(:help_page, title: "Targets", feature: :school_targets, published: true)
        visit electricity_school_progress_index_path(school)
        expect(page).to have_link("Help")
      end

      it 'does not show warning' do
        visit electricity_school_progress_index_path(school)
        expect(page).to_not have_content("We have not received data for your electricity usage for over thirty days")
      end

      it 'shows charts' do
        visit electricity_school_progress_index_path(school)
        expect(page).to have_content("Progress charts")
        expect(page.find('#chart_wrapper_targeting_and_tracking_weekly_electricity_to_date_cumulative_line')).to_not be_nil
        expect(page.find('#chart_wrapper_targeting_and_tracking_weekly_electricity_to_date_line')).to_not be_nil
        expect(page.find('#chart_wrapper_targeting_and_tracking_weekly_electricity_one_year_line')).to_not be_nil
      end

      it 'shows missing page' do
        visit gas_school_progress_index_path(school)
        expect(page).to have_content("We don't have a record of gas being used at your school")
      end

      it 'does not show message about storage heaters' do
        visit electricity_school_progress_index_path(school)
        expect(page).not_to have_content("does not include your storage heater usage")
      end

      context 'when school also has storage heaters' do

        let(:fuel_electricity)          { Schools::FuelConfiguration.new(has_electricity: true, has_storage_heaters: true) }
        let(:school_target_fuel_types) { ["electricity", "storage_heater"] }

        it 'does show message about storage heaters' do
          visit electricity_school_progress_index_path(school)
          expect(page).to have_content("does not include your storage heater usage")
        end

      end
    end

    context 'with out of date data' do
      before(:each) do
        sign_in(admin)
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(false)
      end
      it 'displays a warning electricity progress' do
        visit electricity_school_progress_index_path(school)
        expect(page).to have_content("We have not received data for your electricity usage for over thirty days")
      end
    end

    context 'with error from analytics' do

      before(:each) do
        sign_in(admin)
        allow_any_instance_of(TargetsService).to receive(:progress).and_raise(StandardError.new('test requested'))
      end

      it 'handles errors' do
        visit electricity_school_progress_index_path(school)
        expect(page).to have_content("Unfortunately we are currently unable to display your detailed progress report")
      end
    end

    context 'with partial data' do
      before(:each) do
        sign_in(admin)
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(true)
      end

      context 'and there is missing actual consumption' do
        let(:monthly_usage_kwh)         { [nil,20] }
        let(:cumulative_usage_kwh)      { [nil,30] }

        it 'renders the other data' do
          visit electricity_school_progress_index_path(school)
          expect(page).to have_content('Tracking progress')
          expect(page).to have_content('jan')
          expect(page).to have_content('feb')
          expect(page).to have_content('20')
          expect(page).to have_content('30')
        end

        it 'describes why some consumption data is missing' do
          visit electricity_school_progress_index_path(school)
          expect(page).to have_content("We only have your actual electricity consumption data from 1 Oct 2016")
        end
      end

      context 'and there is missing target consumption and performance' do

        let(:monthly_targets_kwh)       { [nil,15] }
        let(:monthly_performance)       { [nil,0.35] }

        let(:cumulative_targets_kwh)    { [nil,25] }
        let(:cumulative_performance)    { [nil,0.99] }

        it 'renders the other data' do
          visit electricity_school_progress_index_path(school)
          expect(page).to have_content('Tracking progress')
          expect(page).to have_content('15')
          expect(page).to have_content('25')
          expect(page).to have_content('+35%')
          expect(page).to have_content('+99%')
        end

        it 'describes why target consumption data is missing' do
          visit electricity_school_progress_index_path(school)
          expect(page).to have_content('We only have limited consumption data for your school, so we cannot currently calculate a full set of monthly targets or progress')
        end
      end
    end
  end
end
