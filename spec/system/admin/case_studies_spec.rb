require 'rails_helper'

RSpec.describe 'Admin case studies', type: :system do
  let!(:admin) { create(:admin) }
  let!(:case_study) { create(:case_study) }

  describe 'when not logged in' do
    context 'when visiting the index' do
      before do
        visit admin_case_studies_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context 'when editing a case study' do
      before do
        visit edit_admin_case_study_path(case_study)
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'when logged in as a non admin user' do
    let(:staff) { create(:staff) }

    before { sign_in(staff) }

    context 'when visiting the index' do
      before do
        visit admin_case_studies_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You are not authorized to view that page.')
      end
    end
  end

  describe 'when logged in as admin' do
    before { sign_in(admin) }

    context 'when viewing the index' do
      before do
        visit admin_case_studies_path
      end

      it 'lists the case study' do
        expect(page).to have_content(case_study.title)
        expect(page).to have_content(case_study.description)
        expect(page).to have_content(case_study.organisation_type_label)
        expect(page).to have_link('Read case study', href: case_study_download_path(case_study.file))
      end

      it { expect(page).to have_link('Edit') }
      it { expect(page).to have_link('New') }
      it { expect(page).to have_link('Delete') }
    end

    context 'when creating a new case study' do
      before { click_on 'New' }

      context 'with invalid attributes' do
        before do
          within('.description-trix-editor-en') { fill_in_trix with: 'Switch off the lights!' }
          fill_in 'Position', with: '1'
          click_on 'Save case study'
        end

        it { expect(page).to have_content("Title\ncan't be blank") }
      end

      context 'with valid attributes' do
        before do
          within('.description-trix-editor-en') { fill_in_trix with: 'Switch off the lights!' }
          fill_in :case_study_title_en, with: 'Energy saving success'
          fill_in 'Position', with: '1'
          attach_file(:case_study_file_en, Rails.root.join('spec/fixtures/images/newsletter-placeholder.png'))
          click_on 'Save case study'
        end

        it { expect(page).to have_content('Energy saving success') }
      end
    end

    context 'when editing an existing case study' do
      let!(:case_study) { create(:case_study, title_en: 'Old title', position: 1) }

      before do
        before { click_link('Edit', match: :first) }
      end

      context 'with invalid attributes' do
        before do
          fill_in :case_study_title_en, with: ''
          click_on 'Save case study'
        end

        it { expect(page).to have_content("Title *\ncan't be blank") }
      end

      context 'with valid attributes' do
        before do
          fill_in :case_study_title_en, with: 'Updated title'
          click_on 'Save Case study'
        end

        it { expect(page).to have_content('Updated title') }
        it { expect(page).to have_content('Case study was successfully updated.') }
      end
    end

    context 'when deleting a case study' do
      let!(:case_study) { create(:case_study, title_en: 'Delete me', position: 1) }

      before do
        click_on('Delete', match: :first)
      end

      it 'shows the index page' do
        expect(page).to have_current_path(admin_case_studies_path)
      end

      it 'no longer lists the case study' do
        expect(page).not_to have_content('Delete me')
      end
    end
  end
end
