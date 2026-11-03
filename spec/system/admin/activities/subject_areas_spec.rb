# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Activities::SubjectAreas' do
  let(:england_path) { admin_activities_subject_areas_path(country: :england) }

  let!(:admin) { create(:admin) }
  let!(:subject_area) { create(:subject_area, name: 'Mathematics', country: :england) }
  let!(:welsh_area) { create(:subject_area, name: 'Mathemateg', country: :wales) }

  context 'when not signed in' do
    before { visit admin_activities_subject_areas_path }

    it 'is admin only' do
      expect(page).to have_text('You need to sign in or sign up before continuing.')
    end
  end

  context 'when signed in as an admin' do
    before { sign_in(admin) }

    context 'when viewing the subject areas' do
      before { visit admin_activities_subject_areas_path }

      it 'lists the subject areas for the selected country' do
        expect(page).to have_text(subject_area.name)
        expect(page).to have_no_text(welsh_area.name)
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

      it 'flags the subject areas that have not been translated' do
        within 'tr', text: subject_area.name do
          expect(page).to have_css("span[title='No Welsh translation']")
        end
      end
    end

    context with_feature: :activity_classifications do
      before { visit admin_activities_subject_areas_path }

      it 'selects the classifications link in the page nav' do
        within '#page-navigation' do
          expect(page).to have_css("a.current[href='#{admin_activities_labels_path(label_type: 'aim')}']")
        end
      end
    end

    context 'when switching country' do
      before do
        visit admin_activities_subject_areas_path
        within '#country-tabs' do
          click_on 'Wales'
        end
      end

      it 'lists the subject areas for that country' do
        expect(page).to have_text(welsh_area.name)
        expect(page).to have_no_text(subject_area.name)
      end
    end

    context 'when the subject area is in use' do
      before do
        create(:activity_type, subject_areas: [subject_area])
        visit admin_activities_subject_areas_path
      end

      it 'shows the usage count and does not offer to delete it' do
        within 'tr', text: subject_area.name do
          expect(page).to have_text('1 activity')
          expect(page).to have_no_link('Delete')
        end
      end
    end

    context 'when creating a subject area' do
      before do
        visit admin_activities_subject_areas_path
        click_on 'New subject area'
      end

      it 'creates it for the selected country' do
        fill_in :activities_subject_area_name_en, with: 'Science'
        select 'Scotland', from: :activities_subject_area_country

        expect { click_on 'Save' }.to change(Activities::SubjectArea, :count).by(1)
        expect(page).to have_text('Subject area was successfully created.')
        expect(page).to have_current_path(admin_activities_subject_areas_path(country: :scotland))
        expect(Activities::SubjectArea.last.country).to eq('scotland')
      end

      it 'can add a Welsh name' do
        fill_in :activities_subject_area_name_en, with: 'Science'
        fill_in :activities_subject_area_name_cy, with: 'Gwyddon'
        click_on 'Save'

        within 'tr', text: 'Science' do
          expect(page).to have_css("span[title^='Translated:']")
        end
      end

      it 'requires a name' do
        expect { click_on 'Save' }.not_to change(Activities::SubjectArea, :count)
        expect(page).to have_text("can't be blank")
      end
    end

    context 'when editing a subject area' do
      before do
        visit admin_activities_subject_areas_path
        within 'tr', text: subject_area.name do
          click_on 'Edit'
        end
      end

      it 'does not allow the country to be changed' do
        expect(page).to have_no_select(:activities_subject_area_country)
      end

      it 'updates the subject area' do
        fill_in :activities_subject_area_name_en, with: 'Numeracy'
        click_on 'Save'

        expect(page).to have_text('Subject area was successfully updated.')
        expect(page).to have_text('Numeracy')
      end
    end

    context 'when deleting a subject area that is not in use' do
      before do
        visit admin_activities_subject_areas_path
        within 'tr', text: subject_area.name do
          click_on 'Delete'
        end
      end

      it 'deletes the subject area' do
        expect(page).to have_text('Subject area was successfully deleted.')
        expect(page).to have_no_text(subject_area.name)
      end
    end
  end
end
