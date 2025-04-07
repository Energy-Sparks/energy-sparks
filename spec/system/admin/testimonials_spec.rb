require 'rails_helper'

describe 'admin testimonials', :include_application_helper, type: :system do
  let!(:admin) { create(:admin) }
  let!(:case_study) { create(:case_study) }
  let!(:testimonial) { create(:testimonial) }

  describe 'when not logged in' do
    context 'when visiting the index' do
      before do
        visit admin_testimonials_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context 'when editing a testimonial' do
      before do
        visit edit_admin_testimonial_path(testimonial)
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
        visit admin_testimonials_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You are not authorized to view that page.')
      end
    end
  end

  describe 'when logged in' do
    before { sign_in(admin) }

    describe 'Viewing the index' do
      before do
        visit admin_testimonials_path
      end

      it 'lists the testimonial' do
        expect(page).to have_content(testimonial.title)
        expect(page).to have_content(testimonial.quote)
        expect(page).to have_content(testimonial.name)
        expect(page).to have_content(testimonial.role)
        expect(page).to have_content(testimonial.organisation)
        expect(page).to have_content(testimonial.category)
        expect(page).to have_link('Read case study', href: case_study_download_path(testimonial.case_study))
      end

      it { expect(page).to have_link('Edit') }
      it { expect(page).to have_link('New') }
      it { expect(page).to have_link('Delete') }

      context 'when clicking the edit button' do
        before { click_link('Edit', match: :first) }

        it 'shows the testimonial edit page' do
          expect(page).to have_current_path(edit_admin_testimonial_path(testimonial))
        end

        context 'with invalid attributes' do
          before do
            fill_in :testimonial_title_en, with: ''
            fill_in :testimonial_quote_en, with: ''
            fill_in 'Name', with: ''
            fill_in 'Organisation', with: ''
            click_on 'Save'
          end

          it { expect(page).to have_content("Title *\ncan't be blank") }
          it { expect(page).to have_content("Quote *\ncan't be blank") }
          it { expect(page).to have_content("Name *\ncan't be blank") }
          it { expect(page).to have_content("Organisation *\ncan't be blank") }
        end

        context 'with valid attributes' do
          before do
            fill_in :testimonial_title_en, with: 'Updated testimonial title'
            fill_in :testimonial_quote_en, with: 'Updated testimonial quote'
            fill_in 'Name', with: 'Updated name'
            fill_in :testimonial_role_en, with: 'Updated role'
            fill_in 'Organisation', with: 'Updated organisation'
            select 'default', from: 'Category'
            check 'Active'
            click_on 'Save'
          end

          it { expect(page).to have_content('Testimonial was successfully updated') }
          it { expect(page).to have_content('Updated testimonial title') }
          it { expect(page).to have_content('Updated testimonial quote') }
          it { expect(page).to have_content('Updated name') }
          it { expect(page).to have_content('Updated role') }
          it { expect(page).to have_content('Updated organisation') }
          it { expect(page).to have_content('default') }
        end
      end

      context 'when clicking the new button' do
        before { click_link('New') }

        it 'shows the testimonial new page' do
          expect(page).to have_current_path(new_admin_testimonial_path)
        end

        context 'with invalid attributes' do
          before do
            # Submit the form without filling in required fields
            click_on 'Save'
          end

          it { expect(page).to have_content("Title *\ncan't be blank") }
          it { expect(page).to have_content("Quote *\ncan't be blank") }
          it { expect(page).to have_content("Name *\ncan't be blank") }
          it { expect(page).to have_content("Organisation *\ncan't be blank") }
        end

        context 'with valid attributes' do
          before do
            fill_in :testimonial_title_en, with: 'New testimonial title'
            fill_in :testimonial_quote_en, with: 'New testimonial quote'
            fill_in 'Name', with: 'New name'
            fill_in :testimonial_role_en, with: 'New role'
            fill_in 'Organisation', with: 'New organisation'
            select 'default', from: 'Category'
            check 'Active'
            attach_file 'Image', Rails.root + 'spec/fixtures/images/placeholder.png'
            click_on 'Save'
          end

          it { expect(page).to have_content('Testimonial was successfully created') }
          it { expect(page).to have_content('New testimonial title') }
          it { expect(page).to have_content('New testimonial quote') }
          it { expect(page).to have_content('New name') }
          it { expect(page).to have_content('New role') }
          it { expect(page).to have_content('New organisation') }
          it { expect(page).to have_content('default') }
        end
      end

      context 'when clicking the delete button', :js do
        before do
          accept_confirm do
            click_on('Delete', match: :first)
          end
        end

        it 'shows the index page' do
          expect(page).to have_current_path(admin_testimonials_path)
        end

        it 'no longer lists the testimonial' do
          expect(page).not_to have_content(testimonial.title)
        end
      end
    end
  end
end
