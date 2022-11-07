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
        context "and creating a 'New Note'" do
          before do
            click_link text: /New Note/
          end
          it { expect(page).to have_current_path(new_admin_school_note_path(school)) }
          it { expect(page).to have_content("New Note for #{school.name}")}

          it "has default values" do
            expect(find_field('Title').text).to be_blank
            expect(find('trix-editor#note_description')).to have_text('')
            expect(page).to have_select('Fuel type', selected: [])
            expect(page).to have_select('Note type', selected: 'Note')
          end

          context "with required values missing" do
            before do
              click_button 'Save'
            end
            it "has error message on fields" do
              expect(page).to have_content "Title *\ncan't be blank"
              expect(page).to have_content "Description *\ncan't be blank"
            end
          end
          context "with fields filled in" do
            let(:frozen_time) { Time.now }
            before do
              Timecop.freeze(frozen_time)
              fill_in 'Title', with: "Note title"
              fill_in_trix 'trix-editor#note_description', with: 'Note desc'
              select 'Gas', from: 'Fuel type'
              click_button 'Save'
            end
            it "creates new note" do
              expect(page).to have_content "Note"
              expect(page).to have_content "Note title"
              expect(page).to have_content "Note desc"
              expect(page).to have_content "Gas"
              expect(page).to have_content "#{user.email} #{nice_date_times_today(frozen_time)}"
              expect(page).to have_content "Created by #{user.email} at #{nice_date_times_today(frozen_time)}"
            end
            after { Timecop.return }
          end
        end
        it { expect(page).to have_link(text: /New Issue/) }
        context "and creating a 'New Issue'" do
          before do
            click_link text: /New Issue/
          end
          it { expect(page).to have_current_path(new_admin_school_note_path(school, note_type: 'issue')) }
          it { expect(page).to have_content("New Issue for #{school.name}")}

          it "has default values" do
            expect(find_field('Title').text).to be_blank
            expect(find('trix-editor')).to have_text('')
            expect(page).to have_select('Fuel type', selected: [])
            expect(page).to have_select('Note type', selected: 'Issue')
          end

          context "with required values missing" do
            before do
              click_button 'Save'
            end
            it "has error message on fields" do
              expect(page).to have_content "Title *\ncan't be blank"
              expect(page).to have_content "Description *\ncan't be blank"
            end
          end

          context "with fields filled in" do
            let(:frozen_time) { Time.now }
            before do
              Timecop.freeze(frozen_time)
              fill_in 'Title', with: "Issue title"
              fill_in_trix 'trix-editor#note_description', with: 'Issue desc'
              select 'Gas', from: 'Fuel type'
              click_button 'Save'
            end
            it "creates new note" do
              expect(page).to have_content "Issue"
              expect(page).to have_content "Issue title"
              expect(page).to have_content "Issue desc"
              expect(page).to have_content "Gas"
              expect(page).to have_content "#{user.email} #{nice_date_times_today(frozen_time)}"
              expect(page).to have_content "Created by #{user.email} at #{nice_date_times_today(frozen_time)}"
            end
            after { Timecop.return }
          end
        end
      end
    end
  end
end
