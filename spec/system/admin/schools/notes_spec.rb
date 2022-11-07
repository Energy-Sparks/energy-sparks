require 'rails_helper'

RSpec.describe 'school notes', :notes, type: :system, include_application_helper: true do
  let!(:school) { create(:school) }
  let!(:user)   {}

  describe "Viewing school notes admin page" do
    before do
      sign_in(user) if user
      visit admin_school_notes_url(school)
    end

    context 'when not logged in' do
      let!(:user) { }
      it { expect(page).to have_content('You need to sign in or sign up before continuing.') }
    end

    context 'as a non-admin user' do
      let!(:user) { create(:staff) }
      it { expect(page).to have_content('You are not authorized to view that page.') }
    end

    context 'as an admin' do
      let!(:user) { create(:admin) }

      context "with new buttons" do
        it { expect(page).to have_link(text: /New Note/) }
        context "and clicking 'New Note'" do
          before do
            click_link text: /New Note/
          end
          it { expect(page).to have_current_path(new_admin_school_note_path(school)) }
          it { expect(page).to have_content("New Note for #{school.name}")}
        end
        it { expect(page).to have_link(text: /New Issue/) }
        context "and clicking 'New Issue'" do
          before do
            click_link text: /New Issue/
          end
          it { expect(page).to have_current_path(new_admin_school_note_path(school, note_type: 'issue')) }
          it { expect(page).to have_content("New Issue for #{school.name}")}
        end
      end
    end
  end
end
