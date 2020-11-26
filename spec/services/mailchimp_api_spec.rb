
require 'rails_helper'

describe MailchimpApi do

  let(:lists_api) { double(MailchimpMarketing::ListsApi) }
  let(:client) { double(MailchimpMarketing::Client, lists: lists_api) }
  let(:api) { MailchimpApi.new(client) }

  let!(:lists_data) { YAML.load(File.read('spec/fixtures/mailchimp/lists.yml')) }
  let!(:categories_data) { YAML.load(File.read('spec/fixtures/mailchimp/categories.yml')) }
  let!(:interests_data) { YAML.load(File.read('spec/fixtures/mailchimp/interests.yml')) }

  context 'when fetching list details' do

    before do
      allow(lists_api).to receive(:get_all_lists).and_return(lists_data)
      allow(lists_api).to receive(:get_list_interest_categories).and_return(categories_data)
      allow(lists_api).to receive(:list_interest_category_interests).and_return(interests_data)
    end

    it 'return lists' do
      lists = api.lists
      expect(lists.count).to eq(1)
      expect(lists.first.id).to eq('ed205db324')
    end

    it 'returns categories' do
      categories = api.categories('123')
      expect(categories.count).to eq(2)
      expect(categories.first.id).to eq('908f880968')
      expect(categories.first.title).to eq('User type')
      expect(categories.last.id).to eq('fc30f60658')
      expect(categories.last.title).to eq('Local Authority area or school group')
    end

    it 'returns interests' do
      interests = api.interests('123', '456')
      expect(interests.count).to eq(8)
      expect(interests.first.id).to eq('be32b53ee1')
      expect(interests.first.name).to eq('Council /MAT')
      expect(interests.last.id).to eq('85bb2d8115')
      expect(interests.last.name).to eq('Building/ Site Manager or Caretaker')
    end

    it 'returns list with categories and interests' do
      list = api.list_with_interests
      expect(list.id).to eq('ed205db324')
      expect(list.categories.count).to eq(2)
      expect(list.categories.first.id).to eq('908f880968')
      expect(list.categories.first.interests.count).to eq(8)
      expect(list.categories.first.interests.first.id).to eq('be32b53ee1')
    end
  end

  context 'when subscribing new members' do

    let(:list_id) { '123' }
    let(:email_address) { 'john@comp.school' }
    let(:user_name) { 'john' }
    let(:school_name) { 'Comp' }
    let(:interests) { { "123" => "abc", "456" => "def"} }
    let(:tags) { '  one,  two  ' }

    let(:expected_opts) { { skip_merge_validation: true } }
    let(:expected_interests) { {"abc" => true, "def" => true} }
    let(:expected_tags) { ['one','two'] }

    let(:params) { {email_address: email_address, user_name: user_name, school_name: school_name, interests: interests, tags: tags} }

    let(:expected_body) do
      {
        "email_address": email_address,
        "status": "subscribed",
        "merge_fields":
          { "MMERGE7": user_name,
            "MMERGE8": school_name },
        "interests": expected_interests,
        "tags": expected_tags
      }
    end

    it 'subscribes a user with email address and interests' do
      expect(lists_api).to receive(:add_list_member).with(list_id, expected_body, expected_opts).and_return(true)
      api.subscribe(list_id, params)
    end

    it 'handles errors' do
      response_body = "{\"type\":\"http://developer.mailchimp.com/documentation/mailchimp/guides/error-glossary/\",\"title\":\"Invalid Resource\",\"status\":400,\"detail\":\"jules@example.com looks fake or invalid, please enter a real email address.\",\"instance\":\"5156bd8f-569c-49d7-8ed6-a825dd42c932\"}"
      mailchimp_marketing_api_error = MailchimpMarketing::ApiError.new(:status => 400, :response_body => response_body)
      expect(lists_api).to receive(:add_list_member).and_raise(mailchimp_marketing_api_error)
      expect{
        api.subscribe(list_id, params)
      }.to raise_error(MailchimpApi::Error, /jules@example.com looks fake or invalid/)
    end

  end
end
