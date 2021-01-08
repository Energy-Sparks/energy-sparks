require 'rails_helper'

describe MailchimpSubscriber do

  let(:school_group) { create(:school_group, name: 'Sussex') }
  let(:school) { create(:school, school_group: school_group, percentage_free_school_meals: 25) }
  let(:user) { create(:user, name: 'Harry') }

  let(:lists_api) { double(MailchimpMarketing::ListsApi) }
  let(:client) { double(MailchimpMarketing::Client, lists: lists_api) }
  let(:api) { MailchimpApi.new(client) }

  let(:interests) { [OpenStruct.new(id: 'abc333', name: 'Bath and Somerset'), OpenStruct.new(id: 'abc444', name: 'Sussex')] }
  let(:categories) { [OpenStruct.new(id: 'abc222', title: 'Local authority', interests: interests)] }
  let(:list_with_interests) { OpenStruct.new(id: 'abc111', categories: categories) }

  context 'when subscribing' do

    it 'calls api with subscribe params' do
      expect(api).to receive(:list_with_interests).and_return(list_with_interests)
      expect(api).to receive(:subscribe).and_return(true)
      MailchimpSubscriber.new(api).subscribe(school, user)
    end

    it 'builds params' do
      params = MailchimpSubscriber.new(api).mailchimp_signup_params(school, user, list_with_interests)
      expect(params.email_address).to eq(user.email)
      expect(params.tags).to eq('FSM25')
      expect(params.interests).to eq({'abc444' => true})
      expect(params.merge_fields['SCHOOL']).to eq(school.name)
      expect(params.merge_fields['FULLNAME']).to eq(user.name)
    end

  end
end
