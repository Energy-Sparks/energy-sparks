require 'rails_helper'

describe 'targets', type: :system do

  let(:admin)                     { create(:admin) }
  let(:school)                    { create_active_school(name: "Big School")}
  let(:fuel_electricity)          { Schools::FuelConfiguration.new(has_electricity: true) }
  let!(:school_config)            { create(:configuration, school: school, fuel_configuration: fuel_electricity) }
  let(:target)                    { create(:school_target, school: school) }
  let(:months)                    { ['jan', 'feb'] }
  let(:fuel_type)                 { :electricity }
  let(:monthly_targets_kwh)       { [1,2] }
  let(:monthly_usage_kwh)         { [1,2] }
  let(:monthly_performance)       { [-0.25,0.35] }
  let(:cumulative_targets_kwh)    { [1,2] }
  let(:cumulative_usage_kwh)      { [1,2] }
  let(:cumulative_performance)    { [-0.99,0.99] }
  let(:partial_months)            { ['feb'] }

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

  context 'as an admin' do

    context 'with calculated progress' do

      before(:each) do
        sign_in(admin)
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
      end

      it 'redirects to electricity' do
        visit school_progress_index_path(school)
        expect(page).to have_content('Tracking progress')
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
        expect(page).not_to have_content("excluding storage heaters")
      end

      context 'when school also has storage heaters' do

        let(:fuel_electricity)          { Schools::FuelConfiguration.new(has_electricity: true, has_storage_heaters: true) }

        it 'does show message about storage heaters' do
          visit electricity_school_progress_index_path(school)
          expect(page).to have_content("excluding storage heaters")
        end

      end
    end

    context 'with error from analytics' do

      before(:each) do
        sign_in(admin)
        allow_any_instance_of(TargetsService).to receive(:progress).and_raise(StandardError.new('test requested'))
      end

      it 'handles errors' do
        visit electricity_school_progress_index_path(school)
        expect(page).to have_content("Sorry, we encountered an error")
      end
    end
  end
end
