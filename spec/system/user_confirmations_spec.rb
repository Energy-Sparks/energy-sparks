require 'rails_helper'

RSpec.describe 'User confirmations', :schools, type: :system do
  let(:confirmation_token) { 'abc123' }
  let(:valid_password) { 'valid password' }

  include_context 'with a stubbed audience manager'

  before do
    allow(audience_manager).to receive(:subscribe_or_update_contact).and_return(OpenStruct.new(id: 123))
  end

  def fill_in_password(password, confirmation)
    fill_in I18n.t('devise.passwords.edit.new_password'), with: password
    fill_in I18n.t('devise.passwords.edit.confirm_new_password'), with: confirmation
  end

  def fill_in_password_and_register(password, confirmation)
    fill_in_password(password, confirmation)
    check 'user_terms_accepted'
    click_button 'Complete registration'
  end

  shared_examples 'a user registering without alert options' do
    before do
      visit user_confirmation_path(confirmation_token: confirmation_token)
    end

    it 'shows newsletter options' do
      expect(page).to have_content(I18n.t('mailchimp_signups.mailchimp_form.email_preferences'))
    end

    it 'does not show alert subscription options' do
      expect(page).not_to have_content('Energy Sparks alerts:')
    end
  end

  shared_examples 'can set alert preferences' do
    it 'creates alert contact by default' do
      fill_in_password_and_register(valid_password, valid_password)
      expect(user.reload.confirmed?).to be(true)

      expect(user.contacts.count).to eq(1)
      expect(school.contacts.last.email_address).to eq(user.email)
    end

    it 'allows user to opt out' do
      fill_in_password(valid_password, valid_password)
      check 'user_terms_accepted'
      uncheck 'Subscribe to school alerts'
      click_button 'Complete registration'

      expect(user.reload.confirmed?).to be(true)
      expect(user.contacts).to be_empty
    end
  end

  context 'when confirming new user without school' do
    let!(:user) { create(:user, confirmation_token: confirmation_token, confirmed_at: nil, school: nil) }

    it_behaves_like 'a user registering without alert options'
  end

  context 'when confirming new school group user' do
    let!(:user) { create(:group_admin, confirmation_token: confirmation_token, confirmed_at: nil) }

    before do
      visit user_confirmation_path(confirmation_token: confirmation_token)
    end

    it_behaves_like 'a user registering without alert options'
  end

  context 'when confirming new school user' do
    let(:school)  { create(:school) }
    let!(:user)   { create(:staff, confirmation_token: confirmation_token, confirmed_at: nil, school: school) }

    before do
      visit user_confirmation_path(confirmation_token: confirmation_token)
    end

    context 'when validating passwords' do
      context 'with blank password' do
        before do
          fill_in_password_and_register('', '')
        end

        it { expect(page).to have_content("Password can't be blank") }
      end

      context 'with invalid password' do
        before do
          fill_in_password_and_register('password', 'password')
        end

        it { expect(page).to have_content('Password is too short') }
      end

      context 'with mismatched passwords' do
        before do
          fill_in_password_and_register('thisismynewpassword!', 'invalid')
        end

        it { expect(page).to have_content("Password confirmation doesn't match") }
      end
    end

    context 'when successfully registering' do
      context 'with newsletter' do
        it 'subscribes user with default options' do
          expect(audience_manager).to receive(:subscribe_or_update_contact) do |contact, kwargs|
            expect(contact.interests.values.any?).to be(true)
            expect(kwargs[:status]).to eq('subscribed')
          end
          fill_in_password_and_register(valid_password, valid_password)
          expect(page).to have_current_path(school_path(school))
          expect(user.reload.confirmed?).to be(true)
        end

        it 'allows user to opt-out but still adds them to Mailchimp' do
          expect(audience_manager).to receive(:subscribe_or_update_contact) do |contact, kwargs|
            expect(contact.interests.values.all?).to be(false)
            expect(kwargs[:status]).to eq('subscribed')
          end
          fill_in_password(valid_password, valid_password)
          all('input[type=checkbox]').each do |checkbox|
            if checkbox.checked?
              checkbox.click
            end
          end
          check 'user_terms_accepted'
          click_button 'Complete registration'
          expect(page).to have_current_path(school_path(school))
          expect(user.reload.confirmed?).to be(true)
        end
      end

      it_behaves_like 'can set alert preferences'
    end

    context 'when user is a student' do
      let(:school) { create(:school) }
      let!(:user) do
        create(:student, confirmation_token: confirmation_token, confirmed_at: nil, school: school)
      end

      it 'does not show newsletter options' do
        expect(page).not_to have_content(I18n.t('mailchimp_signups.mailchimp_form.email_preferences'))
      end

      context 'when successfully registering' do
        context 'with newsletter' do
          it 'does not add to mailchimp' do
            expect(audience_manager).not_to receive(:subscribe_or_update_contact)
            fill_in_password_and_register(valid_password, valid_password)
            expect(page).to have_current_path(pupils_school_path(school))
            expect(user.reload.confirmed?).to be(true)
          end
        end

        it_behaves_like 'can set alert preferences'
      end
    end
  end

  context 'when following an emailed confirmation link' do
    let!(:user) { create(:staff, confirmation_token: confirmation_token, confirmed_at: nil, email: 'unconfirmed@test.com') }

    before do
      open_email 'unconfirmed@test.com'
      current_email.click_link 'Confirm my account'
      fill_in_password_and_register(valid_password, valid_password)
    end

    it 'logs me in and confirms my account' do
      expect(page).to have_content('Sign Out')
      expect(user.reload.confirmed?).to be(true)
    end
  end

  context 'with an unknown token' do
    it 'handles it sensibly'
  end

  context 'when confirming a user that is already confirmed' do
    context 'when user not logged in' do
      it 'prompts for login'
    end

    context 'when user logged in' do
      it 'redirects'
    end
  end

  context 'when resetting password for existing user' do
    let(:school)  { create(:school) }
    let(:user)    { create(:user, email: 'a@b.com', school: school) }

    before do
      token = user.send(:set_reset_password_token)
      visit edit_user_password_path(user, reset_password_token: token)
    end

    it 'allows password to be set' do
      expect(page).to have_content('Set your password')
      fill_in :user_password, with: valid_password
      fill_in :user_password_confirmation, with: valid_password
      click_button 'Set my password'
      expect(page).to have_content('Your password has been changed successfully')
    end

    it 'does not show checkboxes for subscriptions' do
      expect(page).to have_content('Set your password')
      expect(page).not_to have_content('Energy Sparks alerts:')
      expect(page).not_to have_content(I18n.t('mailchimp_signups.mailchimp_form.email_preferences'))
    end
  end
end
