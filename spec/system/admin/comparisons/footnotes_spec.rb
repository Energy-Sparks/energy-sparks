require 'rails_helper'

describe 'admin comparisons footnotes', type: :system, include_application_helper: true do
  let!(:admin)  { create(:admin) }
  let!(:footnote) { create(:footnote) }

  describe 'when not logged in' do
    context 'when viewing the index' do
      before do
        visit admin_comparisons_footnotes_url
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context 'when editing a footnote' do
      before do
        visit edit_admin_comparisons_footnote_url(footnote)
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'when logged in' do
    before do
      sign_in(admin)
    end

    describe 'Viewing the index' do
      before do
        visit admin_comparisons_footnotes_url
      end

      it 'lists footnote' do
        within('table') do
          expect(page).to have_selector(:table_row, { 'Key' => footnote.key, 'Description' => footnote.description })
        end
      end

      it { expect(page).to have_link('Edit') }

      context 'when clicking the edit button' do
        before { click_link('Edit') }

        it 'shows footnote edit page' do
          expect(page).to have_current_path(edit_admin_comparisons_footnote_path(footnote))
        end

        context 'with invalid attributes' do
          before do
            fill_in 'Key', with: ''
            fill_in 'Description en', with: ''
            click_on 'Save'
          end

          it { expect(page).to have_content("Key *\ncan't be blank") }
          it { expect(page).to have_content("Description en\ncan't be blank") }
        end

        context 'with valid attributes' do
          before do
            fill_in 'Key', with: 'Updated key'
            fill_in 'Description en', with: 'Updated description'
            click_on 'Save'
          end

          it { expect(page).to have_content('Footnote was successfully updated') }
          it { expect(page).to have_selector(:table_row, { 'Key' => 'Updated key', 'Description' => 'Updated description' }) }
        end
      end

      it { expect(page).to have_link('New footnote') }

      context 'when clicking the new button' do
        before { click_link('New footnote') }

        it 'shows footnote new page' do
          expect(page).to have_current_path(new_admin_comparisons_footnote_path)
        end

        context 'with invalid attributes' do
          before do
            fill_in 'Key', with: ''
            fill_in 'Description en', with: ''
            click_on 'Save'
          end

          it { expect(page).to have_content("Key *\ncan't be blank") }
          it { expect(page).to have_content("Description en\ncan't be blank") }
        end

        context 'with valid attributes' do
          before do
            fill_in 'Key', with: 'New key'
            fill_in 'Description en', with: 'New description'
            click_on 'Save'
          end

          it { expect(page).to have_content('Footnote was successfully created') }
          it { expect(page).to have_selector(:table_row, { 'Key' => 'New key', 'Description' => 'New description' }) }
        end
      end

      it { expect(page).to have_link('Delete') }

      context 'when clicking on the delete button' do
        before { click_link('Delete') }

        it 'shows index page' do
          expect(page).to have_current_path(admin_comparisons_footnotes_path)
        end

        it 'no longer lists footnote' do
          within('table') do
            expect(page).not_to have_selector(:table_row, { 'Key' => footnote.key, 'Description' => footnote.description })
          end
        end
      end
    end
  end
end
