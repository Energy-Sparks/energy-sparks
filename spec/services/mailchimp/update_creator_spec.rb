require 'rails_helper'

describe Mailchimp::UpdateCreator do
  subject(:service) { described_class.for(model) }

  shared_examples 'updates are created' do
    let(:existing) { 0 }
    let(:final) { 1 }
    let(:status) { :pending }
    let(:update_type) { :update_contact }

    it 'creates records' do
      expect { service.perform }.to change {
        Mailchimp::Update.where(user: users, status: status, update_type: update_type).count
      }.from(existing).to(final)
    end
  end

  describe '#perform' do
    context 'with user' do
      let!(:model) { create(:user) }

      it 'does nothing by default' do
        expect { service.perform }.not_to change(Mailchimp::Update, :count)
      end

      context 'when name changed' do
        before do
          model.update!(name: 'New')
        end

        it_behaves_like 'updates are created' do
          let(:users) { [model] }
        end
      end
    end
  end
end
