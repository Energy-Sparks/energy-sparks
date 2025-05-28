require 'rails_helper'

describe 'Mailchimp Sign-up' do
  before do
    Flipper.enable :footer
  end

  shared_context 'with an existing user' do
    let(:user) { create(:school_admin) }
    let(:email) { user.email }
    let(:name) { user.name }
    let(:school) { user.school.name }
  end

  shared_context 'with a signed-in user' do
    include_context 'with an existing user'

    before do
      sign_in(user)
    end
  end

  shared_examples 'a functioning sign-up form' do |fill_in_form: true|
    context 'when the form fields are incomplete', if: fill_in_form do
      before do
        click_on 'Subscribe'
      end

      it 'redisplays the page' do
        expect(page).to have_content("Name can't be blank")
        expect(page).to have_field(:email_address, with: email)
      end
    end

    context 'when the form is completed', if: fill_in_form do
      it 'subscribes the user' do
        fill_in :name, with: name
        fill_in :school, with: school
        expect(audience_manager).to receive(:subscribe_or_update_contact) do |subscribed_contact|
          expect(subscribed_contact.email_address).to eq email
          expect(subscribed_contact.name).to eq name
          expect(subscribed_contact.user_role).to be_nil
          expect(subscribed_contact.contact_source).to eq 'Organic'
        end
        click_on 'Subscribe'
        expect(page).to have_content('Subscription confirmed')
      end
    end

    context 'with no interests selected', if: fill_in_form do
      it 'displays an error' do
        fill_in :name, with: name
        fill_in :school, with: school
        all('input[type=checkbox]').each do |checkbox|
          if checkbox.checked?
            checkbox.click
          end
        end
        click_on 'Subscribe'
        expect(page).to have_content(I18n.t('mailchimp_signups.index.select_interests'))
      end
    end

    context 'when the form is pre-filled', unless: fill_in_form do
      it 'shows disabled email and name fields' do
        expect(page).to have_field(:email_address, disabled: true, with: email)
        expect(page).to have_field(:name, disabled: true, with: name)
        expect(page).not_to have_field(:school)
      end

      it 'subscribes the user' do
        expect(audience_manager).to receive(:subscribe_or_update_contact) do |subscribed_contact|
          expect(subscribed_contact.email_address).to eq user.email
          expect(subscribed_contact.name).to eq user.name
          expect(subscribed_contact.user_role).to eq 'School admin'
          expect(subscribed_contact.contact_source).to eq 'User'
        end
        click_on 'Subscribe'
        expect(page).to have_content('Subscription confirmed')
        user.reload
        expect(user.mailchimp_status).to eq('subscribed')
        expect(user.mailchimp_updated_at).not_to be_nil
      end
    end
  end

  describe 'when signing-up via the footer' do
    context 'with a logged in user' do
      include_context 'with a stubbed audience manager'
      include_context 'with a signed-in user'

      before do
        visit terms_and_conditions_path
        within '#newsletter-signup' do
          click_on 'Sign-up now'
        end
      end

      context 'when user has no name' do
        include_context 'with a signed-in user' do
          let(:user) { build(:school_admin, name: nil).tap { |u| u.save(validate: false) } }
        end

        it 'shows disabled email and editable name fields' do
          expect(page).to have_field(:email_address, disabled: true, with: email)
          expect(page).to have_field(:name, disabled: false)
          expect(page).not_to have_field(:school)
        end
      end

      it_behaves_like 'a functioning sign-up form', fill_in_form: false
    end

    context 'with a guest user' do
      include_context 'with a stubbed audience manager'

      context 'when the email address is for a user' do
        include_context 'with an existing user'

        before do
          visit terms_and_conditions_path
          within '#newsletter-signup' do
            fill_in :email_address, with: email
            click_on 'Sign-up now'
          end
        end

        it 'subscribes the user' do
          expect(audience_manager).to receive(:subscribe_or_update_contact) do |subscribed_contact, opts|
            expect(opts[:status]).to eq('subscribed')
            expect(subscribed_contact.email_address).to eq user.email
            expect(subscribed_contact.name).to eq user.name
            expect(subscribed_contact.user_role).to eq 'School admin'
            expect(subscribed_contact.contact_source).to eq 'User'
          end
          fill_in :name, with: name
          click_on 'Subscribe'
          expect(page).to have_content('Subscription confirmed')
          user.reload
          expect(user.mailchimp_status).to eq('subscribed')
          expect(user.mailchimp_updated_at).not_to be_nil
        end
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
    context 'with a logged in user', with_feature: :profile_pages do
      include_context 'with a stubbed audience manager'
      include_context 'with a signed-in user'

      before do
        visit new_mailchimp_signup_path
      end

      it { expect(page).to have_content(I18n.t('users.show.update_email_preferences')) }
    end

    context 'with a logged in user' do
      include_context 'with a stubbed audience manager'
      include_context 'with a signed-in user'

      before do
        visit new_mailchimp_signup_path
      end

      context 'when user has no name' do
        include_context 'with a signed-in user' do
          let(:user) { build(:school_admin, name: nil).tap { |u| u.save(validate: false) } }
        end

        it 'shows disabled email and editable name fields' do
          expect(page).to have_field(:email_address, disabled: true, with: email)
          expect(page).to have_field(:name, disabled: false)
          expect(page).not_to have_field(:school)
        end
      end

      it_behaves_like 'a functioning sign-up form', fill_in_form: false
    end

    context 'with a guest user' do
      include_context 'with a stubbed audience manager'

      context 'when the email address is for a user' do
        include_context 'with an existing user'

        before do
          visit new_mailchimp_signup_path
        end

        it 'subscribes the user' do
          expect(audience_manager).to receive(:subscribe_or_update_contact) do |subscribed_contact, opts|
            expect(opts[:status]).to eq('subscribed')
            expect(subscribed_contact.email_address).to eq user.email
            expect(subscribed_contact.name).to eq user.name
            expect(subscribed_contact.user_role).to eq 'School admin'
            expect(subscribed_contact.contact_source).to eq 'User'
          end
          within '#mailchimp-form' do
            fill_in :email_address, with: email
            fill_in :name, with: name
          end
          click_on 'Subscribe'
          expect(page).to have_content('Subscription confirmed')
        end
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

        it_behaves_like 'a functioning sign-up form'
      end
    end
  end
end
