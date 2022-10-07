require 'rails_helper'

RSpec.describe 'School Users', :schools, type: :system do
  let(:school)                { create(:school) }

  context "when confirming new user" do
    let(:confirmation_token)    { 'abc123' }
    let!(:user)           { create(:user, confirmation_token: confirmation_token, confirmed_at: nil, school: school, email: 'foo@bar.com', name: 'Foo Bar') }

    before :each do
      visit user_confirmation_path(confirmation_token: confirmation_token)
    end

    it 'confirms email address' do
      expect(page).to have_content('Your email address has been successfully confirmed')
    end

    it 'does not allow blank passwords' do
      click_button 'Set my password'
      expect(page).to have_content("Password can't be blank")
    end

    it 'allows newsletter to be subscribed' do
      expect_any_instance_of(MailchimpSubscriber).to receive(:subscribe).with(school, user)
      fill_in :user_password, with: 'abcdef'
      fill_in :user_password_confirmation, with: 'abcdef'
      check 'privacy'
      check 'Subscribe to school alerts'
      click_button 'Set my password'
      expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
    end

    it 'allows alert to be subscribed' do
      fill_in :user_password, with: 'abcdef'
      fill_in :user_password_confirmation, with: 'abcdef'
      check 'privacy'
      check 'Subscribe to school alerts'
      click_button 'Set my password'
      expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
      expect(user.contacts.count).to eq(1)
      expect(school.contacts.last.email_address).to eq('foo@bar.com')
    end

    it 'reshows subscription check boxes after failed validation' do
      check 'privacy'
      fill_in :user_password, with: 'abcdef'
      click_button 'Set my password'
      expect(page).to have_content("Password confirmation doesn't match Password")
      expect(page).to have_content("Energy Sparks can automatically create an alert contact")
      expect(page).to have_content("You can also add the new user to the mailing list for newsletters")
    end
  end

  context "when resetting password for existing user" do
    let(:user)                    { create(:user, email: 'a@b.com') }

    before :each do
      token = user.send(:set_reset_password_token)
      visit edit_user_password_path(user, reset_password_token: token)
    end

    it "should allow password to be set" do
      expect(page).to have_content("Set your password")
      fill_in :user_password, with: 'abcdef'
      fill_in :user_password_confirmation, with: 'abcdef'
      click_button 'Set my password'
      expect(page).to have_content("Your password has been changed successfully")
    end

    it "should not show checkboxes for subscriptions" do
      expect(page).to have_content("Set your password")
      expect(page).not_to have_content("Energy Sparks can automatically create an alert contact")
      expect(page).not_to have_content("You can also add the new user to the mailing list for newsletters")
    end
  end
end
