require 'rails_helper'

describe MailchimpSubscriber do

  let(:school_group) { create(:school_group, name: 'Sussex') }
  let(:school) { create(:school, school_group: school_group, percentage_free_school_meals: 25) }
  let(:staff_role) { create(:staff_role, title: 'Governor') }
  let(:user) { create(:user, name: 'Harry', staff_role: staff_role) }

  let(:lists_api) { double(MailchimpMarketing::ListsApi) }
  let(:client) { double(MailchimpMarketing::Client, lists: lists_api) }
  let(:api) { MailchimpApi.new(client) }

  let(:interests_1) { [OpenStruct.new(id: 'interests_1_1', name: 'Parent'), OpenStruct.new(id: 'interests_1_2', name: 'Governor')] }
  let(:interests_2) { [OpenStruct.new(id: 'interests_2_1', name: 'Bath and Somerset'), OpenStruct.new(id: 'interests_2_2', name: 'Sussex')] }
  let(:category_1) { OpenStruct.new(id: 'category_1', title: 'User type', interests: interests_1) }
  let(:category_2) { OpenStruct.new(id: 'category_2', title: 'Local authority', interests: interests_2) }
  let(:list_with_interests) { OpenStruct.new(id: 'list_with_interests', categories: [category_1, category_2]) }

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
      expect(params.interests).to eq({'interests_1_2' => 'interests_1_2', 'interests_2_2' => 'interests_2_2'})
      expect(params.merge_fields['SCHOOL']).to eq(school.name)
      expect(params.merge_fields['FULLNAME']).to eq(user.name)
    end

  end
end
