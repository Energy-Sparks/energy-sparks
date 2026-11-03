# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Activities::LearningStages' do
  let(:england_path) { admin_activities_learning_stages_path(country: :england) }

  let!(:admin) { create(:admin) }
  let!(:learning_stage) { create(:learning_stage, name: 'Key Stage 1', abbreviation: 'KS1', country: :england) }
  let!(:welsh_stage) { create(:learning_stage, name: 'Cyfnod Allweddol 1', abbreviation: 'PS1', country: :wales) }

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
        expect(page).to have_text(learning_stage.name)
        expect(page).to have_text(learning_stage.abbreviation)
        expect(page).to have_no_text(welsh_stage.name)
      end

      it 'defaults to the first country' do
        within '#country-tabs' do
          expect(page).to have_css("a.active[href='#{england_path}']")
        end
      end

      it 'shows the classification tabs' do
        within '.admin-tasks-classification-tabs-component' do
          expect(page).to have_link('Subject areas')
          expect(page).to have_link('Learning stages')
        end
      end

      it 'flags the learning stages that have not been translated' do
        within 'tr', text: learning_stage.name do
          expect(page).to have_css("span[title='No Welsh translation']", count: 2)
        end
      end
    end

    context with_feature: :activity_classifications do
      before { visit admin_activities_learning_stages_path }

      it 'selects the classifications link in the page nav' do
        within '#page-navigation' do
          expect(page).to have_css("a.current[href='#{admin_activities_labels_path(label_type: 'aim')}']")
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
        expect(page).to have_text(welsh_stage.name)
        expect(page).to have_text(welsh_stage.abbreviation)
        expect(page).to have_no_text(learning_stage.name)
      end
    end

    context 'when the learning stage is in use' do
      before do
        create(:activity_type, learning_stages: [learning_stage])
        visit admin_activities_learning_stages_path
      end

      it 'shows the usage count and does not offer to delete it' do
        within 'tr', text: learning_stage.name do
          expect(page).to have_text('1 activity')
          expect(page).to have_no_link('Delete')
        end
      end
    end

    context 'when creating a learning stage' do
      before do
        visit admin_activities_learning_stages_path
        click_on 'New learning stage'
      end

      it 'creates it for the selected country' do
        fill_in :learning_stage_name_en, with: 'Key Stage 2'
        fill_in :learning_stage_abbreviation_en, with: 'KS2'
        select 'Scotland', from: :learning_stage_country

        expect { click_on 'Save' }.to change(LearningStage, :count).by(1)
        expect(page).to have_text('Learning stage was successfully created.')
        expect(page).to have_current_path(admin_activities_learning_stages_path(country: :scotland))
        expect(LearningStage.last.country).to eq('scotland')
      end

      it 'can add a Welsh name and abbreviation' do
        fill_in :learning_stage_name_en, with: 'Key Stage 2'
        fill_in :learning_stage_name_cy, with: 'Cyfnod Allweddol 2'
        fill_in :learning_stage_abbreviation_en, with: 'KS2'
        fill_in :learning_stage_abbreviation_cy, with: 'CA2'
        click_on 'Save'

        within 'tr', text: 'Key Stage 2' do
          expect(page).to have_css("span[title^='Translated:']", count: 2)
        end
      end

      it 'requires a name and abbreviation' do
        expect { click_on 'Save' }.not_to change(LearningStage, :count)
        expect(page).to have_text("can't be blank", count: 2)
      end
    end

    context 'when editing a learning stage' do
      before do
        visit admin_activities_learning_stages_path
        within 'tr', text: learning_stage.name do
          click_on 'Edit'
        end
      end

      it 'does not allow the country to be changed' do
        expect(page).to have_no_select(:learning_stage_country)
      end

      it 'updates the learning stage' do
        fill_in :learning_stage_name_en, with: 'Foundation Stage'
        click_on 'Save'

        expect(page).to have_text('Learning stage was successfully updated.')
        expect(page).to have_text('Foundation Stage')
      end
    end

    context 'when deleting a learning stage that is not in use' do
      before do
        visit admin_activities_learning_stages_path
        within 'tr', text: learning_stage.name do
          click_on 'Delete'
        end
      end

      it 'deletes the learning stage' do
        expect(page).to have_text('Learning stage was successfully deleted.')
        expect(page).to have_no_text(learning_stage.name)
      end
    end
  end
end
