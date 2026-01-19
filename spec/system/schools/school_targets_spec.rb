# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'managing targets', :include_application_helper do
  let(:fuel_configuration) do
    Schools::FuelConfiguration.new(
      has_solar_pv: false, has_storage_heaters: true, fuel_types_for_analysis: :electric, has_gas: true, has_electricity: true
    )
  end

  before do
    create(:gas_meter, school: test_school)
    create(:electricity_meter, school: test_school)

    allow_any_instance_of(Targets::TargetsService).to receive(:enough_data_to_set_target?).and_return(true)
    allow_any_instance_of(Targets::TargetsService).to receive(:annual_kwh_estimate_required?).and_return(false)

    # Update the configuration rather than creating one, as the school factory builds one
    # and so if we call create(:configuration, school: school) we end up with 2 records for a has_one
    # relationship
    test_school.configuration.update!(fuel_configuration:, aggregate_meter_dates: {
      electricity: {
        start_date: '2021-12-01',
        end_date: '2022-02-01'
      },
      gas: {
        start_date: '2021-03-01',
        end_date: '2022-02-01'
      }
    })
  end

  context 'when school has no target' do
    let(:last_year) { Time.zone.today.last_year }

    context 'with all fuel types' do
      before do
        visit school_school_targets_path(school)
      end

      it 'prompts to create first target' do
        expect(page).to have_content('Set your first energy saving target')
      end

      it 'links to help page if there is one' do
        create(:help_page, title: 'Targets', feature: :school_targets, published: true)
        refresh
        expect(page).to have_link('Help')
      end

      it 'allows targets for all fuel types to be set' do
        fill_in 'Reducing electricity usage by', with: 15
        fill_in 'Reducing gas usage by', with: 15
        fill_in 'Reducing storage heater usage by', with: 25

        click_on 'Set this target'

        expect(page).to have_content('Target successfully created')
        expect(school.has_current_target?).to be(true)
        expect(school.current_target.electricity).to be 15.0
        expect(school.current_target.gas).to be 15.0
        expect(school.current_target.storage_heaters).to be 25.0
      end

      it 'allows just gas and electricity targets to be set' do
        fill_in 'Reducing electricity usage by', with: 15
        fill_in 'Reducing storage heater usage by', with: ''
        click_on 'Set this target'
        expect(page).to have_content('Target successfully created')
        expect(school.has_current_target?).to be(true)
        expect(school.current_target.electricity).to be 15.0
        expect(school.current_target.gas).to be 10.0
        expect(school.current_target.storage_heaters).to be_nil
      end

      it 'allows start date to be specified' do
        start_date = 1.month.ago.to_date
        fill_in 'Start date', with: start_date.strftime('%d/%m/%Y')
        click_on 'Set this target'
        expect(page).to have_content('Target successfully created')
        expect(school.most_recent_target.start_date).to eql start_date
        expect(school.most_recent_target.target_date).to eql start_date.next_year
      end

      it 'adds observation for target' do
        click_on 'Set this target'
        school.reload
        expect(school.current_target.observations.size).to be 1
      end
    end

    context 'with only electricity meters' do
      let(:fuel_configuration) do
        Schools::FuelConfiguration.new(
          has_solar_pv: false, has_storage_heaters: false, fuel_types_for_analysis: :electric, has_gas: false, has_electricity: true
        )
      end

      before do
        service_double = instance_double(AggregateSchoolService)
        allow(AggregateSchoolService).to receive(:new).with(school).and_return(service_double)
        allow(service_double).to receive(:aggregate_school)
          .and_return(build(:meter_collection, :with_aggregate_meter, kwh_data_x48: [1] * 48))
        visit school_school_targets_path(school)
      end

      it 'allows electricity target to be created' do
        expect(page).to have_no_content('Reducing gas usage by')
        expect(page).to have_no_content('Reducing storage heater usage by')

        fill_in 'Reducing electricity usage by', with: 15
        click_on 'Set this target'
        expect(page).to have_content('Target successfully created')
        expect(school.has_current_target?).to be(true)
        expect(school.current_target.electricity).to be 15.0
        expect(school.current_target.gas).to be_nil
        expect(school.current_target.storage_heaters).to be_nil
        expect(school.current_target.electricity_monthly_consumption).not_to be_nil
      end
    end
  end

  context 'with a current target' do
    let!(:target) { create(:school_target, school: test_school) }

    before do
      intervention_type = create(:intervention_type)
      allow_any_instance_of(Recommendations::Actions).to receive(:based_on_energy_use).and_return([intervention_type])
      activity_type = create(:activity_type)
      allow_any_instance_of(Recommendations::Activities).to receive(:based_on_energy_use).and_return([activity_type])
      visit school_school_targets_path(test_school)
    end

    it 'displays the current target page' do
      expect(page).to have_title('Update your energy saving target')
    end

    context 'when there is a help page of the right type' do
      let!(:help_page) { create(:help_page, title: 'Targets', feature: :school_targets, published: true) }

      it 'links to it' do
        refresh
        expect(page).to have_link('Help')
      end
    end

    it 'redirects away from the new target form' do
      visit new_school_school_target_path(test_school, target)
      expect(page).to have_current_path(school_school_targets_path(test_school))
    end

    context 'when I edit the target' do
      it 'allows target to be edited' do
        expect(page).to have_content('Update your energy saving target')
        fill_in 'Reducing electricity usage by', with: 7
        fill_in 'Reducing gas usage by', with: 7
        fill_in 'Reducing storage heater usage by', with: 7
        click_on 'Update our target'
        expect(page).to have_content('Target successfully updated')
        expect(test_school.current_target.electricity).to be 7.0
        expect(test_school.current_target.gas).to be 7.0
        expect(test_school.current_target.storage_heaters).to be 7.0
      end

      it 'does not show a delete button' do
        expect(page).to have_no_link('Delete') unless user.admin?
      end

      it 'validates target values' do
        fill_in 'Reducing gas usage by', with: 123
        click_on 'Update our target'
        expect(page).to have_content('Gas must be less than or equal to 100')
      end
    end
  end

  context 'when viewing an expired target' do
    let!(:last_generated)       { Date.yesterday }
    let!(:start_date)           { Date.yesterday.prev_year }
    let!(:target_date)          { Date.yesterday }
    let!(:target) do
      create(:school_target, school: test_school, start_date:, target_date:, report_last_generated: last_generated)
    end

    def review_text
      'It\'s time to review your progress and set a new target.'
    end

    it 'prompts to review says target is expired' do
      visit school_school_target_path(test_school, target)
      expect(page).to have_content(review_text)
    end

    it 'redirects to this target from index' do
      visit school_school_targets_path(test_school)
      expect(page).to have_content(review_text)
    end

    it 'disallows me from editing an old target' do
      visit edit_school_school_target_path(test_school, target)
      expect(page).to have_content('Cannot edit an expired target')
    end

    context 'when creating a new target' do
      before do
        visit school_school_target_path(test_school, target)
      end

      it 'saves a new target' do
        expect(find_field('Reducing electricity usage by').value).to eq target.electricity.to_s
        fill_in 'Reducing electricity usage by', with: 15
        click_on 'Set this target'
        expect(school.current_target.electricity).to be 15.0
        expect(school.current_target.gas).to eql target.gas
        expect(school.current_target.storage_heaters).to eql target.storage_heaters
        expect(page).to have_content('Target successfully created')
      end

      it 'redirects from the index to the new target when set' do
        click_on 'Set this target'
        # should now redirect here not old target
        visit school_school_targets_path(test_school)
        expect(page).to have_content('Your current target')
      end

      it 'allows me to still view the old target' do
        click_on 'Set this target'
        expect(page).to have_content('Target successfully created')
        visit school_school_target_path(test_school, target)
        expect(page).to have_content('Your current target')
        expect(page).to have_no_content("It's now time to review your progress")
      end
    end

    context 'when there is a newer target' do
      before do
        create(:school_target, school: test_school, start_date: target_date, target_date: target_date + 1.year,
                               report_last_generated: last_generated)
        visit school_school_target_path(test_school, target)
      end

      it 'does not prompt to create another new target' do
        expect(page).to have_content('Your current target')
        expect(page).to have_no_content(review_text)
      end
    end
  end
end

RSpec.shared_examples 'targets are hidden when disabled' do
  let(:expected_path) { school_path(school) }

  context 'with targets disabled for school' do
    before do
      school.update!(enable_targets_feature: false)
    end

    it 'doesn\'t have a link to review targets' do
      visit school_path(school)
      expect(Targets::SchoolTargetService.targets_enabled?(school)).to be false
      within '#my-school-menu' do
        expect(page).to have_no_link('Review targets', href: school_school_targets_path(school))
      end
    end

    it 'redirects from target page' do
      visit school_school_targets_path(school)
      expect(page).to have_current_path(expected_path)
    end
  end
end

describe 'school targets' do
  before do
    sign_in(user) if defined? user
    # visit school_school_targets_path(school)
  end

  let!(:school) { create(:school) }

  context 'when a school admin' do
    let!(:user) { create(:school_admin, school: school) }

    it_behaves_like 'managing targets' do
      let(:test_school) { school }
    end

    it_behaves_like 'targets are hidden when disabled'
  end

  context 'when staff' do
    let!(:user) { create(:staff, school: school) }

    it_behaves_like 'managing targets' do
      let(:test_school) { school }
    end

    it_behaves_like 'targets are hidden when disabled'
  end

  # Admins can delete
  # Admins can view debugging data
  # otherwise same as school admin
  context 'when an admin' do
    let(:user) { create(:admin) }

    it_behaves_like 'managing targets' do
      let(:test_school) { school }
    end

    context 'when viewing a target' do
      before do
        create(:school_target, school:)
        visit school_school_targets_path(school)
      end

      it 'allows target to be deleted' do
        click_on 'Delete'
        expect(page).to have_content('Target successfully removed')
        expect(SchoolTarget.count).to be 0
      end
    end
  end

  context 'when a guest user' do
    let!(:target) { create(:school_target, school:) }

    before do
      visit school_school_targets_path(school)
    end

    it 'requests login' do
      expect(page).to have_content('You need to sign in')
    end
  end

  context 'when a pupil' do
    let!(:target) { create(:school_target, school:) }
    let(:user) { create(:pupil, school:) }

    before do
      visit school_school_targets_path(school)
    end

    it 'doesn\'t allow managing the target' do
      expect(page).to have_content('You are not authorized to access this page.')
    end

    it_behaves_like 'targets are hidden when disabled' do
      let(:expected_path) { pupils_school_path(school) }
    end
  end
end
