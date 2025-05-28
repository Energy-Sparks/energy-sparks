require 'rails_helper'

describe Mailchimp::UserDeletionJob do
  subject(:job) { described_class.new }

  let(:double) { instance_double(Mailchimp::AudienceManager) }

  before do
    allow(Mailchimp::AudienceManager).to receive(:new).and_return(double)
  end

  describe '#can_run?' do
    it 'can only run in production' do
      ClimateControl.modify ENVIRONMENT_IDENTIFIER: 'production' do
        expect(job.can_run?).to be(true)
      end
      ClimateControl.modify ENVIRONMENT_IDENTIFIER: 'test' do
        expect(job.can_run?).to be(false)
      end
    end
  end

  describe '#perform' do
    let(:email_address) { 'test@example.org' }
    let(:name) { 'John Test' }
    let(:school) { 'School of Hard Knocks' }
    let(:tags_to_remove) { %w[FSM30 school-of-hard-knocks] }

    let(:member) do
      member = ActiveSupport::OrderedOptions.new
      member.email_address = email_address
      member.tags = [
        { 'id' => '123', 'name' => 'FSM30' },
        { 'id' => '456', 'name' => 'school-of-hard-knocks' },
        { 'id' => '789', 'name' => 'Other' }
      ]
      member
    end

    around do |example|
      ClimateControl.modify ENVIRONMENT_IDENTIFIER: 'production' do
        example.run
      end
    end

    before do
      allow(double).to receive_messages(update_contact: member, remove_tags_from_contact: true)
    end

    it 'removes user and automatically applied tags' do
      expect(double).to receive(:update_contact) do |contact|
        expect(contact.email_address).to eq(email_address)
        expect(contact.name).to eq(name)
        expect(contact.school).to eq(school)
        expect(contact.tags).to be_empty
        expect(contact.interests).to be_empty
        expect(contact.contact_source).to eq('Organic')
        member
      end
      expect(double).to receive(:remove_tags_from_contact).with(email_address, %w[FSM30 school-of-hard-knocks])
      job.perform(email_address:, name:, school:)
    end
  end
end
