require 'rails_helper'

describe Mailchimp::AudienceManager do
  subject(:service) { described_class.new(client) }

  let(:client) { instance_double(MailchimpMarketing::Client, lists: lists_api) }

  let(:lists_api) { instance_double(MailchimpMarketing::ListsApi) }

  let!(:lists_data) { YAML.safe_load(File.read('spec/fixtures/mailchimp/lists.yml')) }
  let!(:interests_data) { YAML.safe_load(File.read('spec/fixtures/mailchimp/interests.yml')) }
  let!(:categories_data) { YAML.safe_load(File.read('spec/fixtures/mailchimp/categories.yml')) }

  describe '#list' do
    context 'when no lists' do
      before do
        allow(lists_api).to receive(:get_all_lists).and_return([])
      end

      it 'returns empty' do
        expect(service.list).to be_nil
      end
    end

    context 'when lists exist' do
      before do
        allow(lists_api).to receive(:get_all_lists).and_return(lists_data)
      end

      it 'return lists' do
        expect(service.list.id).to eq('aff6ac9f1b')
      end
    end
  end

  describe '#categories' do
    subject(:categories) { service.categories }

    before do
      allow(lists_api).to receive_messages(get_all_lists: lists_data, get_list_interest_categories: categories_data)
    end

    it 'returns categories' do
      expect(categories.count).to eq(1)
      expect(categories.first.id).to eq('54eadf64cc')
      expect(categories.first.title).to eq('Interests')
    end
  end

  describe '#interests' do
    subject(:interests) { service.interests('54eadf64cc') }

    before do
      allow(lists_api).to receive_messages(get_all_lists: lists_data, get_list_interest_categories: categories_data, list_interest_category_interests: interests_data)
    end

    it 'returns interests' do
      expect(interests.count).to eq(5)
      expect(interests.first.id).to eq('4bb520e9fc')
      expect(interests.first.name).to eq('Getting the most out of Energy Sparks')
      expect(interests.last.id).to eq('8f45c9c545')
      expect(interests.last.name).to eq('Tailored advice and support')
      expect(interests.last.i18n_name).to eq('Tailored advice and support')
      expect(interests.last.i18n_description).to include('From time to time')
    end
  end

  describe '#subscribe_or_update_contact' do
    let(:contact) do
      Mailchimp::Contact.new('user@example.org', 'Jane Smith')
    end

    before do
      allow(lists_api).to receive(:get_all_lists).and_return(lists_data)
    end

    it 'subscribes a user with email address and interests' do
      expect(lists_api).to receive(:set_list_member).with(
        'aff6ac9f1b',
        Digest::MD5.hexdigest(contact.email_address.downcase),
        contact.to_mailchimp_hash.merge({ 'status_if_new' => 'subscribed', 'status' => 'subscribed' }),
        { skip_merge_validation: true }
      )
      service.subscribe_or_update_contact(contact, status: 'subscribed')
    end

    it 'subscribes a user without a status by default' do
      expect(lists_api).to receive(:set_list_member).with(
        'aff6ac9f1b',
        Digest::MD5.hexdigest(contact.email_address.downcase),
        contact.to_mailchimp_hash.merge({ 'status_if_new' => 'subscribed' }),
        { skip_merge_validation: true }
      )
      service.subscribe_or_update_contact(contact)
    end
  end

  describe '#update_contact' do
    let(:contact) do
      Mailchimp::Contact.new('user@example.org', 'Jane Smith')
    end

    before do
      allow(lists_api).to receive(:get_all_lists).and_return(lists_data)
    end

    it 'updates contact' do
      expect(lists_api).to receive(:set_list_member).with(
        'aff6ac9f1b',
        Digest::MD5.hexdigest(contact.email_address.downcase),
        contact.to_mailchimp_hash,
        { skip_merge_validation: true }
      )
      service.update_contact(contact)
    end

    it 'updates contact using old email' do
      expect(lists_api).to receive(:set_list_member).with(
        'aff6ac9f1b',
        Digest::MD5.hexdigest('old@example.org'),
        contact.to_mailchimp_hash,
        { skip_merge_validation: true }
      )
      service.update_contact(contact, 'old@example.org')
    end
  end

  describe '#get_list_member' do
    before do
      contact = YAML.safe_load(File.read('spec/fixtures/mailchimp/contact.yml'))
      allow(lists_api).to receive_messages(get_all_lists: lists_data, get_list_member: contact)
    end

    it 'finds a user' do
      expect(lists_api).to receive(:get_list_member).with('aff6ac9f1b', 'john.smith@example.org')
      contact = service.get_list_member('john.smith@example.org')
      expect(contact.email_address).to eq('john.smith@example.org')
      expect(contact.status).to eq('subscribed')
    end
  end

  describe '#process_list_members' do
    before do
      members = YAML.safe_load(File.read('spec/fixtures/mailchimp/members.yml'))
      allow(lists_api).to receive_messages(get_all_lists: lists_data, get_list_members_info: members)
    end

    it 'lists all contacts' do
      expect(lists_api).to receive(:get_list_members_info).with('aff6ac9f1b', offset: 0, count: 1000)
      members = service.process_list_members
      expect(members.map(&:email_address)).to contain_exactly('jane.doe@example.org', 'john.smith@example.org')
    end
  end
end
