require 'rails_helper'

RSpec.describe 'Admin newsletters', type: :system do
  let!(:admin) { create(:admin) }

  describe 'when not logged in' do
    context 'when visiting the index' do
      before { visit admin_newsletters_path }

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end

    context 'when creating a new newsletter' do
      before { visit new_admin_newsletter_path }

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'when logged in as admin' do
    before { sign_in(admin) }

    context 'when viewing the index' do
      before { visit admin_newsletters_path }

      it { expect(page).to have_link('New') }
    end

    context 'when creating a newsletter' do
      let(:url) { 'https://sausage-dogs-and-draught-excluders.com' }
      let(:title) { 'Save energy with a sausage dog' }

      before do
        visit admin_newsletters_path
        click_on 'New'
      end

      context 'with invalid attributes' do
        before do
          click_on 'Save'
        end

        it { expect(page).to have_content("Title *\ncan't be blank") }
        it { expect(page).to have_content("Url *\ncan't be blank") }
      end

      context 'when publishing without an image' do
        before do
          check :newsletter_published
          click_on 'Save'
        end

        it { expect(page).to have_content('No image attached') }
      end

      context 'with valid attributes' do
        before do
          fill_in 'Title', with: title
          fill_in 'Url', with: url
          attach_file 'Image', Rails.root.join('spec/fixtures/images/boiler.jpg')
          fill_in 'Published on', with: Time.zone.today
          check :newsletter_published

          click_on 'Save'
        end

        it 'shows the newsletter details' do
          expect(page).to have_content(title)
          expect(page).to have_content(url)
          expect(page).to have_content('Newsletter was successfully created.')
        end
      end
    end

    context 'when editing a newsletter' do
      let!(:newsletter) do
        create(:newsletter, title: 'Original Title', url: 'https://example.com', published_on: Time.zone.today)
      end

      before do
        visit admin_newsletters_path
        click_on 'Edit'
      end

      context 'with valid attributes' do
        before do
          fill_in 'Title', with: 'Updated Title'
          click_on 'Save'
        end

        it { expect(page).to have_content('Updated Title') }
        it { expect(page).to have_content('Newsletter was successfully updated.') }
      end
    end

    context 'when deleting a newsletter' do
      let!(:newsletter) do
        create(:newsletter, title: 'Delete Me', url: 'https://example.com', published_on: Time.zone.today)
      end

      before do
        visit admin_newsletters_path
        click_on 'Delete'
      end

      it 'removes the newsletter' do
        expect(page).to have_content('Newsletter was successfully destroyed.')
        expect(page).not_to have_content('Delete Me')
      end
    end
  end
end
