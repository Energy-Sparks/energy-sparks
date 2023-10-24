require 'rails_helper'

describe 'Mailchimp signup', type: :system do
  describe 'mailchimp signup page' do
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
end
