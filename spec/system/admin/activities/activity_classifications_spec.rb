# frozen_string_literal: true

require 'rails_helper'

describe 'Admin activity classifications' do
  let!(:admin) { create(:admin) }
  let!(:category) { create(:activity_category) }
  let!(:topic_energy) { create(:label, label_type: :topic, name: 'Energy') }
  let!(:topic_climate_change) { create(:label, label_type: :topic, name: 'Climate change') }
  let!(:aim_understanding) { create(:label, label_type: :aim, name: 'Increase our understanding') }
  let!(:duration_one_hour) { create(:label, label_type: :duration, name: 'One hour') }
  let!(:subject_area_science) { create(:subject_area, name: 'Science', country: :england) }
  let!(:subject_area_social_studies) do
    create(:subject_area, name: 'Social studies', country: :scotland)
  end
  let!(:learning_stage_ks2) do
    create(:learning_stage, name: 'Key Stage 2', abbreviation: 'KS2', country: :england)
  end

  before { sign_in(admin) }

  context 'when the feature is disabled', without_feature: :activity_classifications do
    before { visit new_admin_activity_type_path }

    it 'does not render the classification controls' do
      expect(page).to have_no_text('Classifications')
      expect(page).to have_no_select('tom-select', multiple: true, visible: :all)
    end
  end

  context 'when the feature is enabled', with_feature: :activity_classifications do
    describe 'New activity' do
      before { visit new_admin_activity_type_path }

      it 'displays one subject area select per country' do
        expect(page).to have_select('activity_type_subject_area_ids_england', visible: :all)
        expect(page).to have_select('activity_type_subject_area_ids_scotland', visible: :all)
        expect(page).to have_select('activity_type_subject_area_ids_wales', visible: :all)
      end

      it 'displays one learning stage select per country' do
        expect(page).to have_select('activity_type_learning_stage_ids_england', visible: :all)
        expect(page).to have_select('activity_type_learning_stage_ids_scotland', visible: :all)
        expect(page).to have_select('activity_type_learning_stage_ids_wales', visible: :all)
      end

      it "displays only that country's subject areas in each select" do
        expect(page).to have_select('activity_type_subject_area_ids_england',
                                    with_options: [subject_area_science.name], visible: :all)
        expect(page).to have_select('activity_type_subject_area_ids_scotland',
                                    with_options: [subject_area_social_studies.name], visible: :all)
      end

      describe 'saving labels' do
        before do
          fill_in_activity('Labelled activity')
          select topic_energy.name, from: 'activity_type_topic_ids'
          select topic_climate_change.name, from: 'activity_type_topic_ids'
          select aim_understanding.name, from: 'activity_type_aim_ids'
          select duration_one_hour.name, from: 'activity_type_duration_ids'

          click_on 'Save'
        end

        it { expect(page).to have_text('Activity was successfully created.') }

        it 'saves the topics' do
          expect(saved_activity_type.topics.map(&:name))
            .to contain_exactly(topic_energy.name, topic_climate_change.name)
        end

        it 'saves the aims' do
          expect(saved_activity_type.aims.map(&:name)).to contain_exactly(aim_understanding.name)
        end

        it 'saves the durations' do
          expect(saved_activity_type.durations.map(&:name)).to contain_exactly(duration_one_hour.name)
        end
      end

      describe 'saving classifications scoped to a country' do
        before do
          fill_in_activity('Classified activity')
          select subject_area_science.name, from: 'activity_type_subject_area_ids_england'
          select subject_area_social_studies.name, from: 'activity_type_subject_area_ids_scotland'
          select learning_stage_ks2.name, from: 'activity_type_learning_stage_ids_england'

          click_on 'Save'
        end

        it { expect(page).to have_text('Activity was successfully created.') }

        it 'saves the subject areas from every country' do
          expect(saved_activity_type.subject_areas.map(&:name))
            .to contain_exactly(subject_area_science.name, subject_area_social_studies.name)
        end

        it 'saves the learning stages' do
          expect(saved_activity_type.learning_stages.map(&:name)).to contain_exactly(learning_stage_ks2.name)
        end
      end

      describe 'saving fuel types' do
        before do
          fill_in_activity('Fuelled activity')
          select 'Gas', from: 'activity_type_fuel_type'
          select 'Electricity', from: 'activity_type_fuel_type'

          click_on 'Save'
        end

        it { expect(page).to have_text('Activity was successfully created.') }

        it 'saves the selected fuel types' do
          expect(saved_activity_type.fuel_type).to include('gas', 'electricity')
        end

        it 'does not save fuel types that were not selected' do
          expect(saved_activity_type.fuel_type.compact_blank).to contain_exactly('gas', 'electricity')
        end
      end
    end

    describe 'Editing an activity' do
      let!(:activity_type) { create(:activity_type, activity_category: category, topics: [topic_energy]) }

      before { visit edit_admin_activity_type_path(activity_type) }

      it 'shows the currently selected topics' do
        expect(page).to have_select('activity_type_topic_ids', selected: topic_energy.name, visible: :all)
      end

      context 'when a classification is cleared' do
        before do
          unselect topic_energy.name, from: 'activity_type_topic_ids'
          click_on 'Save'
        end

        it { expect(page).to have_text('Activity was successfully updated.') }

        it 'removes the classification' do
          expect(activity_type.reload.topics).to be_empty
        end
      end

      context 'when subject areas are spread across country selects' do
        before do
          activity_type.update!(subject_area_ids: [subject_area_science.id, subject_area_social_studies.id])
          visit edit_admin_activity_type_path(activity_type)
        end

        it 'shows England its own selections' do
          expect(page).to have_select('activity_type_subject_area_ids_england',
                                      selected: subject_area_science.name, visible: :all)
        end

        it 'shows Scotland its own selections' do
          expect(page).to have_select('activity_type_subject_area_ids_scotland',
                                      selected: subject_area_social_studies.name, visible: :all)
        end
      end

      context 'when every country is cleared' do
        before do
          activity_type.update!(subject_area_ids: [subject_area_science.id, subject_area_social_studies.id])
          visit edit_admin_activity_type_path(activity_type)
          unselect subject_area_science.name, from: 'activity_type_subject_area_ids_england'
          unselect subject_area_social_studies.name, from: 'activity_type_subject_area_ids_scotland'
          click_on 'Save'
        end

        it { expect(page).to have_text('Activity was successfully updated.') }

        it 'clears the selections made in every country' do
          expect(activity_type.reload.subject_areas).to be_empty
        end
      end
    end

    describe 'with Tom Select loaded', :js do
      before { visit new_admin_activity_type_path }

      it 'initialises a Tom Select widget for each select' do
        %w[
          topic_ids
          aim_ids
          duration_ids
          fuel_type
          subject_area_ids_england
          subject_area_ids_scotland
          subject_area_ids_wales
          learning_stage_ids_england
          learning_stage_ids_scotland
          learning_stage_ids_wales
        ].each do |select_id|
          expect(page).to have_css("#activity_type_#{select_id} + .ts-wrapper")
        end
      end
    end
  end

  private

  def fill_in_activity(name)
    fill_in :activity_type_name_en, with: name
    fill_in :activity_type_summary_en, with: 'A summary'
    fill_in 'Score', with: 20
    fill_in 'Maximum frequency', with: 5
  end

  def saved_activity_type
    @saved_activity_type ||= ActivityType.i18n.order(:id).last
  end
end
