require 'rails_helper'

describe 'Mailchimp Sign-up' do
  before do
    Flipper.enable :footer
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
      context 'when the email address is for a user' do
        it 'subscribes the user'
      end

      context 'with a new email address' do
        it 'allows the user to sign up'

        context 'when the user is already subscribed' do
          it 'does not cause an error'
        end
      end
    end
  end

  describe 'when visiting the mailchimp form' do
    context 'with a guest user' do
      context 'when the email address is for a user' do
        it 'subscribes the user'
      end

      context 'with a new email address' do
        it 'allows the user to sign up'

        context 'when the user is already subscribed' do
          it 'does not cause an error'
        end
      end
    end
  end

  describe '(OLD) mailchimp signup page' do
    let!(:newsletter) { create(:newsletter) }
    let(:interests)             { [double(id: 1, name: 'Interest One')] }
    let(:categories)            { [double(id: 1, title: 'Category One', interests: interests)] }
    let(:list_with_interests)   { double(id: 1, categories: categories) }

    before do
      allow_any_instance_of(MailchimpApi).to receive(:list_with_interests).and_return(list_with_interests)
      expect_any_instance_of(MailchimpApi).to receive(:subscribe).and_return(true)
      visit root_path
    end

    it 'allows the user to sign up' do
      within '.mailchimp' do
        fill_in 'Your email address', with: 'foo@bar.com'
        click_on 'Continue'
      end

      expect(page).to have_content('Sign up to the Energy Sparks newsletter')

      fill_in :merge_fields_FULLNAME, with: 'Foo'
      choose 'Interest One'
      click_on 'Subscribe'

      expect(page).to have_content('Subscription confirmed')
    end
  end

  describe 'Newsletter Signup Footer' do
    before do
      Flipper.enable :footer
      visit terms_and_conditions_path
    end

    # Not doing a full mailchimp test here, just that the form submits to the right place
    context 'when signing up' do
      let!(:newsletter) { create(:newsletter) }
      let(:interests) { [OpenStruct.new(id: 1, name: 'Interest One')] }
      let(:categories) { [OpenStruct.new(id: 1, title: 'Category One', interests: interests)] }
      let(:list_with_interests) { OpenStruct.new(id: 1, categories: categories) }

      before do
        allow_any_instance_of(MailchimpApi).to receive(:list_with_interests).and_return(list_with_interests)
        allow_any_instance_of(MailchimpApi).to receive(:subscribe).and_return(true)
      end

      context 'when email provided' do
        before do
          within '#newsletter-signup' do
            fill_in :email_address, with: 'foo@bar.com'
            click_on 'Sign-up now'
          end
        end

        it { expect(page).to have_content('Sign up to the Energy Sparks newsletter') }
        it { expect(page).to have_field(:email_address, with: 'foo@bar.com') }
      end

      context 'when email is not provided' do
        before do
          within '#newsletter-signup' do
            fill_in :email_address, with: ''
            click_on 'Sign-up now'
          end
        end

        it { expect(page).to have_content('Sign up to the Energy Sparks newsletter') }
        it { expect(page).to have_field(:email_address, with: nil) }
      end
    end
  end
end
