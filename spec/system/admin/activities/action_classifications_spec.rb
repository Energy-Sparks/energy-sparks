# frozen_string_literal: true

require 'rails_helper'

describe 'Admin action classifications' do
  let!(:admin) { create(:admin) }
  let!(:intervention_type_group) { create(:intervention_type_group) }
  let!(:focus_heating_waste) { create(:label, label_type: :focus, name: 'Heating waste') }
  let!(:focus_gas_out_of_hours) { create(:label, label_type: :focus, name: 'Gas out of hours') }

  before { sign_in(admin) }

  context 'when the feature is disabled', without_feature: :activity_classifications do
    before { visit new_admin_intervention_type_path }

    it 'does not show focuses' do
      expect(page).to have_no_css('#intervention_type_focus_ids', visible: :all)
    end
  end

  context 'when the feature is enabled', with_feature: :activity_classifications do
    describe 'New action' do
      before { visit new_admin_intervention_type_path }

      it 'shows all focus options' do
        expect(page).to have_select('intervention_type_focus_ids',
                                    with_options: [focus_heating_waste.name, focus_gas_out_of_hours.name],
                                    visible: :all)
      end

      it 'shows all fuel type options' do
        expect(page).to have_select('intervention_type_fuel_type',
                                    with_options: InterventionType::VALID_FUEL_TYPES.map { |type|
                                      type.to_s.humanize
                                    },
                                    visible: :all)
      end

      describe 'Creating an action' do
        let(:saved_intervention_type) { InterventionType.i18n.order(:id).last }

        before do
          fill_in_action('Focused action')
          select focus_heating_waste.name, from: 'intervention_type_focus_ids'
          select focus_gas_out_of_hours.name, from: 'intervention_type_focus_ids'
          select 'Gas', from: 'intervention_type_fuel_type'
          select 'Solar', from: 'intervention_type_fuel_type'

          click_on 'Save'
        end

        it { expect(page).to have_text('Action was successfully created.') }

        it 'saves the selected focuses' do
          expect(saved_intervention_type.focuses.map(&:name))
            .to contain_exactly(focus_heating_waste.name, focus_gas_out_of_hours.name)
        end

        it 'saves the selected fuel types' do
          expect(saved_intervention_type.fuel_type).to include('gas', 'solar')
        end

        it 'does not save fuel types that were not selected' do
          expect(saved_intervention_type.fuel_type.compact_blank).to contain_exactly('gas', 'solar')
        end
      end
    end

    describe 'Editing an action' do
      let!(:intervention_type) do
        create(:intervention_type, intervention_type_group:, focuses: [focus_heating_waste])
      end

      before { visit edit_admin_intervention_type_path(intervention_type) }

      it 'shows the currently selected focuses' do
        expect(page).to have_select('intervention_type_focus_ids',
                                    selected: focus_heating_waste.name, visible: :all)
      end

      context 'when updating options' do
        before do
          unselect focus_heating_waste.name, from: 'intervention_type_focus_ids'
          select 'Gas', from: 'intervention_type_fuel_type'
          click_on 'Save'
        end

        it { expect(page).to have_text('Action was successfully updated.') }

        it 'removes the focus' do
          expect(intervention_type.reload.focuses).to be_empty
        end
      end
    end

    describe 'with Tom Select loaded', :js do
      before { visit new_admin_intervention_type_path }

      it 'initialises a Tom Select widget for each control' do
        expect(page).to have_css('#intervention_type_focus_ids + .ts-wrapper')
        expect(page).to have_css('#intervention_type_fuel_type + .ts-wrapper')
      end
    end
  end

  private

  def fill_in_action(name)
    fill_in :intervention_type_name_en, with: name
    fill_in :intervention_type_summary_en, with: 'A summary'
    fill_in 'Score', with: 10
    fill_in 'Maximum frequency', with: 3
  end
end
