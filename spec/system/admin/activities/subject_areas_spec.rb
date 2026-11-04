# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Activities::SubjectAreas' do
  let(:england_path) { admin_activities_subject_areas_path(country: :england) }

  let!(:admin) { create(:admin) }
  let!(:subject_area_english) { create(:subject_area, name: 'Enrichment', country: :england) }
  let!(:subject_area_welsh) { create(:subject_area, name: 'Mathematics and Numeracy', country: :wales) }

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
        expect(page).to have_text(subject_area_english.name)
      end

      it 'does not list the subject areas for other countries' do
        expect(page).to have_no_text(subject_area_welsh.name)
      end

      it 'defaults to the first country' do
        within '#country-tabs' do
          expect(page).to have_css("a.active[href='#{england_path}']")
        end
      end
    end

    context with_feature: :activity_classifications do
      before { visit admin_activities_subject_areas_path }

      it 'selects the classifications link in the page nav' do
        within '#page-navigation' do
          expect(page).to have_css("a.current[href='#{admin_activities_classifications_path(task_type: 'activity')}']")
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
        expect(page).to have_text(subject_area_welsh.name)
      end

      it 'does not list the subject areas for other countries' do
        expect(page).to have_no_text(subject_area_english.name)
      end
    end

    context 'when creating a subject area' do
      before do
        visit admin_activities_subject_areas_path
        click_on 'New subject area'
      end

      context 'when creating a subject area for the selected country' do
        before do
          fill_in :activities_subject_area_name_en, with: 'Science'
          select 'Scotland', from: :activities_subject_area_country
          click_on 'Save'
        end

        it { expect(page).to have_text('Subject area was successfully created.') }
        it { expect(page).to have_text('Science') }
        it { expect(page).to have_current_path(admin_activities_subject_areas_path(country: :scotland)) }
      end

      context 'with missing information' do
        before do
          fill_in :activities_subject_area_name_en, with: ''
          click_on 'Save'
        end

        it { expect(page).to have_text("Name\ncan't be blank") }
      end
    end

    context 'when editing a subject area' do
      before do
        visit admin_activities_subject_areas_path
        within 'tr', text: subject_area_english.name do
          click_on 'Edit'
        end
      end

      it 'does not allow the country to be changed' do
        expect(page).to have_no_select(:activities_subject_area_country)
      end

      context 'when updating the subject area' do
        before do
          fill_in :activities_subject_area_name_en, with: 'Numeracy'
          click_on 'Save'
        end

        it { expect(page).to have_text('Subject area was successfully updated.') }
        it { expect(page).to have_text('Numeracy') }
      end
    end

    context 'when deleting a subject area that is not in use' do
      before do
        visit admin_activities_subject_areas_path
        within 'tr', text: subject_area_english.name do
          click_on 'Delete'
        end
      end

      it 'deletes the subject area' do
        expect(page).to have_text('Subject area was successfully deleted.')
        expect(page).to have_no_text(subject_area_english.name)
      end
    end
  end
end
