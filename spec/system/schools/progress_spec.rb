require 'rails_helper'

describe 'targets', type: :system do

  let(:admin)                     { create(:admin) }
  let(:school)                    { create_active_school(name: "Big School")}
  let(:target)                    { create(:school_target, school: school) }
  let(:months)                    { ['jan', 'feb'] }
  let(:fuel_type)                 { :electricity }
  let(:monthly_targets_kwh)       { [1,2] }
  let(:monthly_usage_kwh)         { [1,2] }
  let(:monthly_performance)       { [-0.25,0.35] }
  let(:cumulative_targets_kwh)    { [1,2] }
  let(:cumulative_usage_kwh)      { [1,2] }
  let(:cumulative_performance)    { [-0.99,0.99] }

  let(:progress) do
    TargetsProgress.new(
        fuel_type: fuel_type,
        months: months,
        monthly_targets_kwh: monthly_targets_kwh,
        monthly_usage_kwh: monthly_usage_kwh,
        monthly_performance: monthly_performance,
        cumulative_targets_kwh: cumulative_targets_kwh,
        cumulative_usage_kwh: cumulative_usage_kwh,
        cumulative_performance: cumulative_performance
    )
  end

  context 'as an admin' do

    before(:each) do
      sign_in(admin)
      allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
    end

    it 'shows target page' do
      visit school_progress_index_path(school)
      expect(page).to have_content('Tracking progress')
      expect(page).to have_content('jan')
      expect(page).to have_content('feb')
      expect(page).to have_content('-25%')
      expect(page).to have_content('+35%')
      expect(page).to have_content('-99%')
      expect(page).to have_content('+99%')
    end
  end
end
