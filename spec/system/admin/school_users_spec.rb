require 'rails_helper'

RSpec.describe 'School Users', :schools, type: :system do

  # let!(:school_group)   { create(:school_group, name: 'BANES') }
  # let(:school_name)           { 'Oldfield Park Infants'}
  # let(:school)         { create_active_school(name: school_name, school_group: school_group) }

  let(:school)                { create(:school) }
  let(:confirmation_token)    { 'abc123' }
  let!(:user)                  { create(:user, confirmation_token: confirmation_token, confirmed_at: nil, school: school, email: 'foo@bar.com', name: 'Foo Bar') }

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
    end

  end

end
