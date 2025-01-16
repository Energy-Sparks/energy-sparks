require 'rails_helper'

describe 'Mailchimp Sign-up' do
  before do
    Flipper.enable :footer
  end

  shared_context 'with a stubbed audience manager' do
    let(:list) { OpenStruct.new(id: '1234') }
    let(:interests) { [OpenStruct.new(id: 'abcd', name: 'Newsletter')] }
    let(:categories) do
      [
        OpenStruct.new(id: 1, title: 'Category'),
        OpenStruct.new(id: 2, title: 'Email Preferences')
      ]
    end
    let(:audience_manager) { instance_double(Mailchimp::AudienceManager) }

    before do
      allow(Mailchimp::AudienceManager).to receive(:new).and_return(audience_manager)
      allow(audience_manager).to receive_messages(list: list, categories: categories, interests: interests)
    end
  end

  shared_examples 'a functioning sign-up form' do
    context 'when form is incomplete' do
      before do
        click_on 'Subscribe'
      end

      it 'redisplays the page' do
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_field(:email_address, with: email)
      end
    end

    context 'when the form is completed' do
      before do
        allow(audience_manager).to receive(:subscribe_or_update_contact).and_return(OpenStruct.new(id: 123))
        fill_in :name, with: name
        fill_in :school, with: school
      end

      it 'subscribes the user' do
        expect(audience_manager).to receive(:subscribe_or_update_contact)
        click_on 'Subscribe'
        expect(page).to have_content('Subscription confirmed')
      end
    end
  end

  describe 'when signing-up via the footer' do
    context 'with a signed-in user' do
      let(:user) { create(:school_admin) }

      before do
        sign_in(user)
        visit terms_and_conditions_path
      end

      it 'does not show the email field'

      context 'when signing up' do
        it 'subscribes the user'
      end
    end

    context 'with a guest user' do
      include_context 'with a stubbed audience manager'

      context 'when the email address is for a user' do
        it 'subscribes the user'
      end

      context 'with a new email address' do
        let(:email) { 'person@example.org' }
        let(:name) { 'Jane Smith' }
        let(:school) { 'Bash St Primary' }

        before do
          visit terms_and_conditions_path
          within '#newsletter-signup' do
            fill_in :email_address, with: email
            click_on 'Sign-up now'
          end
        end

        it 'populates the email address' do
          expect(page).to have_field(:email_address, with: email)
        end

        it_behaves_like 'a functioning sign-up form'
      end
    end
  end

  describe 'when visiting the mailchimp form' do
    context 'with a guest user' do
      include_context 'with a stubbed audience manager'

      context 'when the email address is for a user' do
        it 'subscribes the user'
      end

      context 'with a new email address' do
        let(:email) { 'person@example.org' }
        let(:name) { 'Jane Smith' }
        let(:school) { 'Bash St Primary' }

        before do
          visit new_mailchimp_signup_path
          within '#mailchimp-form' do
            fill_in(:email_address, with: email)
          end
        end

        it 'populates the email address' do
          expect(page).to have_field(:email_address, with: email)
        end

        it_behaves_like 'a functioning sign-up form'
      end
    end
  end
end
