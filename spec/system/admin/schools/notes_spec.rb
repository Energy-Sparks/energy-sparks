require 'rails_helper'

RSpec.describe 'school notes', :notes, type: :system, include_application_helper: true do
  let!(:school) { create(:school) }
  let!(:note)   {}
  let!(:notes)  { [] }
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

      context "and creating a new note" do
        Note.note_types.keys.each do |note_type|
          it { expect(page).to have_link(text: /New #{note_type.capitalize}/) }
          context "of type #{note_type}" do
            before do
              click_link text: /New #{note_type.capitalize}/
            end
            it { expect(page).to have_current_path(new_admin_school_note_path(school, note_type: note_type)) }
            it { expect(page).to have_content("New #{note_type.capitalize} for #{school.name}")}

            it "has default values" do
              expect(find_field('Title').text).to be_blank
              expect(find('trix-editor#note_description')).to have_text('')
              expect(page).to have_select('Fuel type', selected: [])
              expect(page).to have_select('Note type', selected: note_type.capitalize)
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
                fill_in 'Title', with: "#{note_type} title"
                fill_in_trix 'trix-editor#note_description', with: "#{note_type} desc"
                select 'Gas', from: 'Fuel type'
                click_button 'Save'
              end
              it "creates new note" do
                expect(page).to have_content "#{note_type.capitalize}"
                expect(page).to have_content "#{note_type} title"
                expect(page).to have_content "#{note_type} desc"
                expect(page).to have_content "Gas"
                expect(page).to have_content "#{user.email} #{nice_date_times_today(frozen_time)}"
                expect(page).to have_content "Created by #{user.email} at #{nice_date_times_today(frozen_time)}"
              end
              after { Timecop.return }
            end
          end
        end
      end

      context "and editing a note" do
        Note.note_types.keys.each do |note_type|
          context "of type #{note_type}" do
            let!(:note) { create(:note, school: school, note_type: note_type, fuel_type: :electricity, created_by: user) }
            it { expect(page).to have_link('Edit') }
            before do
              click_link("Edit")
            end
            it "shows edit form" do
              expect(page).to have_field('Title', with: note.title)
              expect(find_field('note[description]', type: :hidden).value).to eq(note.description.to_plain_text)
              expect(page).to have_select('Fuel type', selected: note.fuel_type.capitalize)
              expect(page).to have_select('Note type', selected: note_type.capitalize)
            end
            context "and saving new values" do
              let(:frozen_time) { Time.now }
              let(:new_note_type) { Note.note_types.keys.excluding(note_type).first.capitalize }
              before do
                Timecop.freeze(frozen_time)
                fill_in 'Title', with: "#{note_type} title"
                fill_in_trix 'trix-editor#note_description', with: "#{note_type} desc"
                select 'Gas', from: 'Fuel type'
                select new_note_type, from: 'Note type'
                click_button 'Save'
              end
              it "saves new values" do
                expect(page).to have_content new_note_type
                expect(page).to have_content "#{note_type} title"
                expect(page).to have_content "#{note_type} desc"
                expect(page).to have_content "Gas"
                expect(page).to have_content "#{user.email} #{nice_date_times_today(frozen_time)}"
                expect(page).to have_content "Created by #{user.email} at #{nice_date_times_today(note.created_at)}"
              end
              after { Timecop.return }
            end
          end
        end
      end
    end
  end
end
