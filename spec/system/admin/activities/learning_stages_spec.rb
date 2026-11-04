# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Activities::LearningStages' do
  let(:england_path) { admin_activities_learning_stages_path(country: :england) }

  let!(:admin) { create(:admin) }
  let!(:learning_stage_english) { create(:learning_stage, name: 'Key Stage 1', abbreviation: 'KS1', country: :england) }
  let!(:learning_stage_welsh) do
    create(:learning_stage, name: 'Progression Step 1', abbreviation: 'PS1', country: :wales)
  end

  context 'when not signed in' do
    before { visit admin_activities_learning_stages_path }

    it 'is admin only' do
      expect(page).to have_text('You need to sign in or sign up before continuing.')
    end
  end

  context 'when signed in as an admin' do
    before { sign_in(admin) }

    context 'when viewing the learning stages' do
      before { visit admin_activities_learning_stages_path }

      it 'lists the learning stages for the selected country' do
        expect(page).to have_text(learning_stage_english.name)
        expect(page).to have_text(learning_stage_english.abbreviation)
      end

      it 'does not list the learning stages for other countries' do
        expect(page).to have_no_text(learning_stage_welsh.name)
        expect(page).to have_no_text(learning_stage_welsh.abbreviation)
      end

      it 'defaults to the first country' do
        within '#country-tabs' do
          expect(page).to have_css("a.active[href='#{england_path}']")
        end
      end
    end

    context with_feature: :activity_classifications do
      before { visit admin_activities_learning_stages_path }

      it 'selects the classifications link in the page nav' do
        within '#page-navigation' do
          expect(page).to have_css("a.current[href='#{admin_activities_classifications_path(task_type: 'activity')}']")
        end
      end
    end

    context 'when switching country' do
      before do
        visit admin_activities_learning_stages_path
        within '#country-tabs' do
          click_on 'Wales'
        end
      end

      it 'lists the learning stages for that country' do
        expect(page).to have_text(learning_stage_welsh.name)
        expect(page).to have_text(learning_stage_welsh.abbreviation)
      end

      it 'does not list the learning stages for other countries' do
        expect(page).to have_no_text(learning_stage_english.name)
        expect(page).to have_no_text(learning_stage_english.abbreviation)
      end
    end

    context 'when creating a learning stage' do
      before do
        visit admin_activities_learning_stages_path
        click_on 'New learning stage'
      end

      context 'when creating a learning stage for the selected country' do
        before do
          fill_in :learning_stage_name_en, with: 'Second Level'
          fill_in :learning_stage_abbreviation_en, with: 'Second'
          select 'Scotland', from: :learning_stage_country
          click_on 'Save'
        end

        it { expect(page).to have_text('Learning stage was successfully created.') }
        it { expect(page).to have_text('Second Level') }
        it { expect(page).to have_text('Scotland') }
      end

      context 'with missing information' do
        before do
          fill_in :learning_stage_name_en, with: ''
          fill_in :learning_stage_abbreviation_en, with: ''
          click_on 'Save'
        end

        it { expect(page).to have_text("Name\ncan't be blank") }
        it { expect(page).to have_text("Abbreviation\ncan't be blank") }
      end
    end

    context 'when editing a learning stage' do
      before do
        visit admin_activities_learning_stages_path
        within 'tr', text: learning_stage_english.name do
          click_on 'Edit'
        end
      end

      it 'does not allow the country to be changed' do
        expect(page).to have_no_select(:learning_stage_country)
      end

      context 'when updating the learning stage' do
        before do
          fill_in :learning_stage_name_en, with: 'Foundation Stage'
          click_on 'Save'
        end

        it { expect(page).to have_text('Learning stage was successfully updated.') }
        it { expect(page).to have_text('Foundation Stage') }
      end
    end

    context 'when deleting a learning stage that is not in use' do
      before do
        visit admin_activities_learning_stages_path
        within 'tr', text: learning_stage_english.name do
          click_on 'Delete'
        end
      end

      it 'deletes the learning stage' do
        expect(page).to have_text('Learning stage was successfully deleted.')
        expect(page).to have_no_text(learning_stage_english.name)
      end
    end
  end
end
