require 'rails_helper'

RSpec.describe 'School Users', :schools, type: :system do
  let(:confirmation_token) { 'abc123' }

  context "when confirming new user without school" do
    let!(:user) { create(:user, confirmation_token: confirmation_token, confirmed_at: nil, school: nil, email: 'foo@bar.com', name: 'Foo Bar') }

    it 'does not show newsletter or alert subscription options' do
      visit user_confirmation_path(confirmation_token: confirmation_token)
      expect(page).to have_content('Your email address has been successfully confirmed')
      expect(page).not_to have_content("Energy Sparks alerts:")
      expect(page).not_to have_content("Newsletters are our main communication channel for:")
    end
  end

  context "when confirming new user without school but with school group" do
    let(:school_group)  { create(:school_group, name: 'some MAT') }
    let!(:user)         { create(:user, confirmation_token: confirmation_token, confirmed_at: nil, school: nil, school_group: school_group, email: 'foo@bar.com', name: 'Foo Bar') }

    it 'shows newsletter but not alert subscription options' do
      visit user_confirmation_path(confirmation_token: confirmation_token)
      expect(page).to have_content('Your email address has been successfully confirmed')
      expect(page).not_to have_content("Energy Sparks alerts:")
      expect(page).to have_content("Newsletters are our main communication channel for:")
    end
  end

  context "when confirming new user with school" do
    let(:school)  { create(:school) }
    let!(:user)   { create(:user, confirmation_token: confirmation_token, confirmed_at: nil, school: school, email: 'foo@bar.com', name: 'Foo Bar') }

    before do
      visit user_confirmation_path(confirmation_token: confirmation_token)
    end

    it 'confirms email address' do
      expect(page).to have_content('Your email address has been successfully confirmed')
    end

    it 'does not allow blank passwords' do
      click_button 'Complete registration'
      expect(page).to have_content("Password can't be blank")
    end

    it 'allows newsletter to be subscribed (the default)' do
      expect_any_instance_of(MailchimpSubscriber).to receive(:subscribe).with(user)
      fill_in :user_password, with: 'abcdef'
      fill_in :user_password_confirmation, with: 'abcdef'
      check 'privacy'
      click_button 'Complete registration'
      expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
    end

    it 'allows newsletter to be unsubscribed' do
      expect_any_instance_of(MailchimpSubscriber).not_to receive(:subscribe)
      fill_in :user_password, with: 'abcdef'
      fill_in :user_password_confirmation, with: 'abcdef'
      check 'privacy'
      uncheck 'Subscribe to newsletters'
      click_button 'Complete registration'
      expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
    end

    it 'allows alert to be subscribed (the default)' do
      fill_in :user_password, with: 'abcdef'
      fill_in :user_password_confirmation, with: 'abcdef'
      check 'privacy'
      click_button 'Complete registration'
      expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
      expect(user.contacts.count).to eq(1)
      expect(school.contacts.last.email_address).to eq('foo@bar.com')
    end

    it 'allows alert to be unsubscribed' do
      fill_in :user_password, with: 'abcdef'
      fill_in :user_password_confirmation, with: 'abcdef'
      check 'privacy'
      uncheck 'Subscribe to school alerts'
      click_button 'Complete registration'
      expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
      expect(user.contacts.count).to eq(0)
    end

    it 'reshows subscription check boxes after failed validation' do
      check 'privacy'
      fill_in :user_password, with: 'abcdef'
      uncheck 'Subscribe to school alerts'
      uncheck 'Subscribe to newsletters'
      click_button 'Complete registration'
      expect(page).to have_content("Password confirmation doesn't match Password")
      expect(page).not_to have_checked_field("Subscribe to school alerts")
      expect(page).not_to have_checked_field("Subscribe to newsletters")
    end
  end

  context "when resetting password for existing user" do
    let(:school)  { create(:school) }
    let(:user)    { create(:user, email: 'a@b.com', school: school) }

    before do
      token = user.send(:set_reset_password_token)
      visit edit_user_password_path(user, reset_password_token: token)
    end

    it "allows password to be set" do
      expect(page).to have_content("Set your password")
      fill_in :user_password, with: 'abcdef'
      fill_in :user_password_confirmation, with: 'abcdef'
      click_button 'Set my password'
      expect(page).to have_content("Your password has been changed successfully")
    end

    it "does not show checkboxes for subscriptions" do
      expect(page).to have_content("Set your password")
      expect(page).not_to have_content("Energy Sparks alerts:")
      expect(page).not_to have_content("Newsletters are our main communication channel for:")
    end
  end
end
