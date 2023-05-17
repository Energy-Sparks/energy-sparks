require 'rails_helper'

describe 'target progress report', type: :system do

  let(:school)                    { create_active_school(name: "Big School")}

  let(:fuel_electricity) { Schools::FuelConfiguration.new(has_electricity: true, has_storage_heaters: false) }
  let(:school_target_fuel_types)  { ["electricity"] }

  let!(:electricity_progress)     { build(:fuel_progress, fuel_type: :electricity, progress: 0.99, target: 20, usage: 15) }
  let!(:school_target)            { create(:school_target, school: school, electricity_progress: electricity_progress) }

  let(:first)                   { Date.new(Date.today.year, 1, 1) }
  let(:second)                  { Date.new(Date.today.year, 2, 1) }
  let(:months)                    { [first, second] }
  let(:fuel_type)                 { :electricity }

  let(:monthly_usage_kwh)         { [10,20] }
  let(:monthly_targets_kwh)       { [8,15] }
  let(:monthly_performance)       { [-0.25,0.35] }

  let(:cumulative_usage_kwh)      { [10,30] }
  let(:cumulative_targets_kwh)    { [8,25] }
  let(:cumulative_performance)    { [-0.99,0.99] }

  let(:partial_months)            { [false, true] }
  let(:percentage_synthetic)      { [0, 0]}

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
        partial_months: partial_months,
        percentage_synthetic: percentage_synthetic
    )
  end

  let(:recent_data)   { true }

  before(:each) do
    allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
    #update here to avoid duplicating records
    school.configuration.update!(fuel_configuration: fuel_electricity, school_target_fuel_types: school_target_fuel_types)
    sign_in(user)
  end

  context 'as a school admin' do
    let(:user)  { create(:school_admin, school: school) }

    context 'visiting old progress path' do
      before(:each) do
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(true)
      end
      it 'redirects the index to electricity' do
        visit school_progress_index_path(school)
        expect(page).to have_content('Tracking progress')
      end
      it 'redirects the individual paths path' do
        visit electricity_school_progress_index_path(school)
        expect(page).to have_content('Tracking progress')
      end
    end

    it 'redirects to management dashboard if feature is disabled for school' do
      school.update!(enable_targets_feature: false)
      visit electricity_school_school_target_progress_index_path(school, school_target)
      expect(page).to have_current_path(school_path(school))
    end

    context 'with error from analytics' do
      before(:each) do
        allow_any_instance_of(TargetsService).to receive(:progress).and_raise(StandardError.new('test requested'))
      end
      it 'handles errors' do
        visit electricity_school_progress_index_path(school)
        expect(page).to have_content("Unfortunately due to an error we are currently unable to display your detailed progress report")
      end
    end

    context 'with current target' do
      before(:each) do
        allow_any_instance_of(TargetsService).to receive(:progress).and_return(progress)
        allow_any_instance_of(TargetsService).to receive(:recent_data?).and_return(recent_data)
        create(:help_page, title: "Targets", feature: :school_targets, published: true)
        visit electricity_school_school_target_progress_index_path(school, school_target)
      end

      context "with a link to the expired target report" do
        context "and an expired target for the same fuel" do
          let!(:expired_target) { create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday, electricity: 1) }
          before { refresh }
          it 'links to the expired target report' do
            expect(page).to have_link("View last year’s target report", href: electricity_school_school_target_progress_index_path(school, expired_target))
          end
        end

        context "and an expired target for a different fuel" do
          let!(:expired_target) { create(:school_target, school: school, start_date: Date.yesterday.prev_year, target_date: Date.yesterday, electricity: nil, gas: 1) }
          before { refresh }
          it 'does not link to the expired target report' do
            expect(page).to_not have_link("View last year’s target report")
          end
        end

        context "no expired target" do
          it { expect(page).to_not have_link("View last year’s target report") }
        end
      end

      it 'includes summary of the target dates' do
        expect(page).to have_content("Your school has set a target to reduce its electricity usage by #{school_target.electricity}% between #{school_target.start_date.to_s(:es_full)} and #{school_target.target_date.to_s(:es_full)}")
      end

      it 'shows the electricity progress report with expected data' do
        expect(page).to have_content('Tracking progress')
        expect(page).to have_content(first.strftime("%b"))
        expect(page).to have_content(second.strftime("%b"))
        expect(page).to have_content('-25%')
        expect(page).to have_content('+35%')
        expect(page).to have_content('-99%')
        expect(page).to have_content('+99%')
      end

      it 'says I am not achieving my target' do
        expect(page).to have_content("Unfortunately you are using +99% more electricity than last year")
      end

      context 'if I am achieving my target' do
        let(:cumulative_performance)    { [-0.99,-0.99] }
        it 'says I am' do
          expect(page).to have_content("Well done, you are using -99% less electricity than last year")
        end
      end

      it 'links to this school target' do
        expect(page).to have_link("Review targets", href: school_school_target_path(school, school_target))
      end

      it 'links to help page if there is one' do
        expect(page).to have_link("Help")
      end

      it 'does not show warning if data is up to date' do
        expect(page).to_not have_content("We have not received data for your electricity usage for over thirty days")
      end

      it 'does not show message about storage heaters' do
        expect(page).not_to have_content("This report only shows progress on reducing your electricity usage")
      end

      it 'shows the charts' do
        expect(page).to have_content("Progress charts")
        expect(page.find('#chart_wrapper_targeting_and_tracking_weekly_electricity_to_date_cumulative_line')).to_not be_nil
        expect(page.find('#chart_wrapper_targeting_and_tracking_weekly_electricity_to_date_line')).to_not be_nil
        expect(page.find('#chart_wrapper_targeting_and_tracking_weekly_electricity_one_year_line')).to_not be_nil
      end

      it 'shows warning message for gas' do
        visit gas_school_progress_index_path(school)
        expect(page).to have_content("We don't have a record of gas being used at your school")
      end

      context 'with out of date data' do
        let(:recent_data)   { false }
        it 'displays a warning electricity progress' do
          expect(page).to have_content("We have not received data for your electricity usage for over thirty days")
        end
        it 'does not say whether I am achieving my target' do
          expect(page).to_not have_content("Unfortunately you are using +99% more electricity than last year")
        end
      end

      context 'when school also has storage heaters' do
        let(:fuel_electricity)          { Schools::FuelConfiguration.new(has_electricity: true, has_storage_heaters: true) }
        let(:school_target_fuel_types) { ["electricity", "storage_heater"] }

        it 'does show message about storage heaters' do
          expect(page).to have_content("This report only shows progress on reducing your electricity usage")
          expect(page).to have_link("storage heater progress report")
        end

        it 'doesnt show message if no storage heater target' do
          school_target.update!(storage_heaters: nil)
          refresh
          expect(page).to_not have_content("This report only shows progress on reducing your electricity usage")
          expect(page).to_not have_link("storage heater progress report")
        end
      end

      context 'with partial data' do
        let(:start_date)  { (Date.today-6.months).iso8601 }
        let(:end_date)  { (Date.today-1.day).iso8601 }

        before(:each) do
          school.configuration.update!(suggest_estimates_fuel_types: ["electricity"], aggregate_meter_dates: {"electricity"=>{"start_date"=>start_date, "end_date"=>end_date}})
          visit electricity_school_school_target_progress_index_path(school, school_target)
        end

        context 'and there is missing actual consumption' do
          let(:monthly_usage_kwh)         { [nil,20] }
          let(:cumulative_usage_kwh)      { [nil,30] }

          it 'renders the other data' do
            expect(page).to have_content('Tracking progress')
            expect(page).to have_content('Jan')
            expect(page).to have_content('Feb')
            expect(page).to have_content('20')
            expect(page).to have_content('30')
          end

          it 'describes why some consumption data is missing' do
            expect(page).to have_content("We only have data on your electricity consumption from #{Date.parse(start_date).strftime("%b %Y")}")
          end

          it 'shows prompt to add estimate' do
            expect(page).to have_content("If you can supply an estimate of your annual consumption then we can generate a more detailed progress report")
          end

          it 'doesnt show prompt if different fuel type' do
            school.configuration.update!(suggest_estimates_fuel_types: ["gas"])
            refresh
            expect(page).to_not have_content("gas")
          end

          it 'doesnt show prompt if estimate not needed' do
            school.configuration.update!(suggest_estimates_fuel_types: [""])
            refresh
            expect(page).to_not have_content("If you can supply an estimate of your annual consumption then we can generate a more detailed progress report")
          end

        end

        context 'and there is missing target consumption and performance' do
          let(:monthly_targets_kwh)       { [nil,15] }
          let(:monthly_performance)       { [nil,0.35] }
          let(:cumulative_targets_kwh)    { [nil,25] }
          let(:cumulative_performance)    { [nil,0.99] }

          it 'renders the other data' do
            expect(page).to have_content('Tracking progress')
            expect(page).to have_content('15')
            expect(page).to have_content('25')
            expect(page).to have_content('+35%')
            expect(page).to have_content('+99%')
          end

          it 'describes why target consumption data is missing' do
            expect(page).to have_content('We only have limited historical consumption data for your school, so we cannot currently calculate a full set of monthly targets or progress')
          end
        end
      end

    end

    context 'with expired target' do
      let(:start_date)      { Date.today.last_year.beginning_of_month}
      let(:target_date)     { Date.today.beginning_of_month}

      let(:first)                   { start_date }
      let(:second)                  { target_date.prev_month.beginning_of_month }

      #version of the target with a saved progress report
      let!(:school_target)  { create(:school_target, school: school, electricity_progress: electricity_progress, electricity_report: progress, start_date: start_date, target_date: target_date) }

      before(:each) do
        visit electricity_school_school_target_progress_index_path(school, school_target)
      end

      it 'includes summary of the target dates' do
        expect(page).to have_content("Your school set a target to reduce its electricity usage by #{school_target.electricity}% between #{school_target.start_date.to_s(:es_full)} and #{school_target.target_date.to_s(:es_full)}")
      end

      it 'shows the electricity progress report with expected data' do
        expect(page).to have_content('Results of reducing')
        expect(page).to have_content(first.strftime("%b"))
        expect(page).to have_content(second.strftime("%b"))
        expect(page).to have_content('-25%')
        expect(page).to have_content('+35%')
        expect(page).to have_content('-99%')
        expect(page).to have_content('+99%')
      end

      it 'says I am not achieving my target' do
        expect(page).to have_content("Unfortunately you didn't achieve your goal to reduce your electricity usage")
      end

      context 'if I am achieving my target' do
        let(:cumulative_performance)    { [-0.99,-0.99] }
        it 'says I am' do
          expect(page).to have_content("Well done! You managed to reduce your electricity usage by -99%")
        end
      end

      it 'does not show the charts' do
        expect(page).to_not have_content("Progress charts")
      end

      it 'has a footnote to indicate this is a snapshot' do
        expect(page).to have_content("Any later updates to your school configuration or data will not be reflected in these historical results.")
      end
    end
  end
end
