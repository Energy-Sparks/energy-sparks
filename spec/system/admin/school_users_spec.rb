require 'rails_helper'

RSpec.describe 'School Users', :schools, type: :system do
  let(:school)                { create(:school) }
  let(:confirmation_token)    { 'abc123' }
  let!(:user)           { create(:user, confirmation_token: confirmation_token, confirmed_at: nil, school: school, email: 'foo@bar.com', name: 'Foo Bar') }

  context "as new user" do

    context "when confirming" do

      before :each do
        visit user_confirmation_path(confirmation_token: confirmation_token)
      end

      it 'confirms email address' do
        expect(page).to have_content('Your email address has been successfully confirmed')
      end

      it 'allows newsletter to be subscribed' do
        expect_any_instance_of(MailchimpSubscriber).to receive(:subscribe).with(school, user)
        check 'privacy'
        check 'Subscribe to school alerts'
        click_button 'Set my password'
        expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
      end

      it 'allows alert to be subscribed' do
        check 'privacy'
        check 'Subscribe to school alerts'
        click_button 'Set my password'
        expect(page).to have_content('Your password has been changed successfully. You are now signed in.')
        expect(user.contacts.count).to eq(1)
        expect(school.contacts.last.email_address).to eq('foo@bar.com')
      end

      it 'reshows subscription check boxes after failed validation' do
        check 'privacy'
        fill_in :user_password, with: 'abc'
        fill_in :user_password_confirmation, with: 'xyz'
        click_button 'Set my password'
        expect(page).to have_content("Password confirmation doesn't match Password")
        expect(page).to have_content("Energy Sparks can automatically create an alert contact")
        expect(page).to have_content("You can also add the new user to the mailing list for newsletters")
      end
    end

  end

end
