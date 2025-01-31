require 'rails_helper'

describe Mailchimp::AudienceUpdater do
  subject(:service) { described_class.new }

  describe '#perform' do
    let(:double) { instance_double(Mailchimp::AudienceManager) }

    before do
      allow(Mailchimp::AudienceManager).to receive(:new).and_return(double)
    end

    def create_contact(email_address, **fields)
      contact = ActiveSupport::OrderedOptions.new
      contact.email_address = email_address
      fields.each do |keyword, value|
        contact[keyword] = value
      end
      contact
    end

    context 'when finding contacts' do
      # slightly artificial but checking to ensure service filters by role
      let!(:user) { create(:pupil, mailchimp_status: 'subscribed') }

      it 'ignores pupil users' do
        expect(double).not_to receive(:update_contact)
        service.perform
      end
    end

    context 'when pushing to mailchimp' do
      let(:member) { create_contact(user.email, status: 'subscribed') }
      let!(:user) { create(:school_admin, mailchimp_status: 'archived') }

      context 'with successful API call' do
        before do
          allow(double).to receive(:update_contact).and_return(member)
        end

        it 'updates attributes on success' do
          service.perform
          user.reload
          expect(user.mailchimp_status).to eq('subscribed')
          expect(user.mailchimp_updated_at).not_to be_nil
        end

        it 'does not add interests' do
          expect(double).to receive(:update_contact) do |contact|
            expect(contact.interests).to be_empty
            member
          end
          service.perform
        end

        it 'calls right API' do
          expect(double).to receive(:update_contact) do |contact|
            expect(contact.email_address).to eq(user.email)
            member
          end
          service.perform
        end

        context 'when user is nonsubscribed' do
          let(:member) { create_contact(user.email, status: 'transactional') }

          it 'normalises the status' do
            service.perform
            user.reload
            expect(user.mailchimp_status).to eq('nonsubscribed')
            expect(user.mailchimp_updated_at).not_to be_nil
          end
        end
      end

      context 'with unsuccessful call' do
        it 'does not throw exception' do
          allow(double).to receive(:update_contact).and_raise StandardError
          expect(EnergySparks::Log).to receive(:exception)
          service.perform
        end
      end

      context 'when user tags need updating' do
        it 'also updates the tags'
      end
    end
  end
end
