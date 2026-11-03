# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Activities::Labels system spec' do
  let!(:admin) { create(:admin) }
  let!(:aim) { create(:label, label_type: :aim, name: 'Reduce energy use') }
  let!(:duration) { create(:label, label_type: :duration, name: 'One hour') }

  context 'when not signed in' do
    before { visit admin_activities_labels_path(label_type: 'aim') }

    it 'is admin only' do
      expect(page).to have_text('You need to sign in or sign up before continuing.')
    end
  end

  context 'when signed in as an admin' do
    before do
      Flipper.enable(:activity_classifications)
      sign_in(admin)
    end

    context 'when viewing the labels' do
      before { visit admin_activities_labels_path(label_type: 'aim') }

      it 'lists the labels for the selected classification' do
        expect(page).to have_text(aim.name)
      end

      it 'does not list the labels for other classifications' do
        expect(page).to have_no_text(duration.name)
      end

      it 'highlights the matching classifications link' do
        within '#page-navigation' do
          expect(page).to have_css("a.current[href='#{admin_activities_labels_path(label_type: 'aim')}']")
        end
      end

      it 'does not highlight the other classifications links' do
        within '#page-navigation' do
          expect(page).to have_no_css("a.current[href='#{admin_activities_labels_path(label_type: 'duration')}']")
        end
      end
    end

    context 'when switching between the classifications' do
      before do
        visit admin_activities_labels_path(label_type: 'aim')
        within '.admin-tasks-classification-tabs-component' do
          click_on 'Durations'
        end
      end

      it 'lists the labels for that classification' do
        expect(page).to have_text(duration.name)
        expect(page).to have_no_text(aim.name)
      end
    end

    context 'when the classification is not known' do
      before { visit admin_activities_labels_path(label_type: 'unknown') }

      it 'falls back to the aims' do
        expect(page).to have_text(aim.name)
        within '.admin-tasks-classification-tabs-component' do
          expect(page).to have_css("a.active[href='#{admin_activities_labels_path(label_type: 'aim')}']")
        end
      end
    end

    context 'when creating a label from a classification tab' do
      before do
        visit admin_activities_labels_path(label_type: 'topic')
        click_on 'New topic'
        fill_in :task_label_name_en, with: 'Renewable energy'
        click_on 'Save'
      end

      it 'creates the label and stays on the classification' do
        expect(page).to have_text('Topic was successfully created.')
        expect(page).to have_current_path(admin_activities_labels_path(label_type: 'topic'))
        within '.admin-tasks-classification-tabs-component' do
          expect(page).to have_css("a.active[href='#{admin_activities_labels_path(label_type: 'topic')}']")
        end
      end
    end

    context 'when creating a label without a name' do
      before do
        visit admin_activities_labels_path(label_type: 'topic')
        click_on 'New topic'
        click_on 'Save'
      end

      it 'reports the error and stays on the classification' do
        expect(page).to have_text("can't be blank")
        expect(page).to have_current_path(admin_activities_labels_path(label_type: 'topic'))
        within '.admin-tasks-classification-tabs-component' do
          expect(page).to have_css("a.active[href='#{admin_activities_labels_path(label_type: 'topic')}']")
        end
      end
    end

    context 'when editing a label from a classification tab' do
      let!(:topic) { create(:label, label_type: :topic, name: 'Energy') }

      before do
        visit admin_activities_labels_path(label_type: 'topic')
        within 'tr', text: topic.name do
          click_on 'Edit'
        end
        fill_in :task_label_name_en, with: 'Renewable energy'
        click_on 'Save'
      end

      it 'updates the label and stays on the classification' do
        expect(page).to have_text('Topic was successfully updated.')
        expect(page).to have_current_path(admin_activities_labels_path(label_type: 'topic'))
        within '.admin-tasks-classification-tabs-component' do
          expect(page).to have_css("a.active[href='#{admin_activities_labels_path(label_type: 'topic')}']")
        end
      end
    end

    context 'when deleting a label that is not in use' do
      before do
        visit admin_activities_labels_path(label_type: 'aim')
        within 'tr', text: aim.name do
          click_on 'Delete'
        end
      end

      it 'deletes the label' do
        expect(page).to have_text('Aim was successfully deleted.')
        expect(page).to have_no_text(aim.name)
      end
    end

    context 'when deleting a label that is in use' do
      before do
        create(:activity_type, aims: [aim])
        visit admin_activities_labels_path(label_type: 'aim')
      end

      it 'does not offer to delete the label' do
        within 'tr', text: aim.name do
          expect(page).to have_no_link('Delete')
        end
      end
    end
  end
end
