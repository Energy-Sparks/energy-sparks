require 'rails_helper'

RSpec.describe DashboardMessage, type: :model do
  let(:messageable) { create(:school) }

  describe 'validations' do
    subject { build(:dashboard_message) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:message) }
  end

  describe '.add_or_insert_message!' do
    let(:message) { 'There is something wrong with the meters.' }

    context 'when there is no message' do
      it 'creates a message' do
        expect { described_class.add_or_insert_message!(messageable, message) }.to change(described_class, :count).by(1)
      end
    end

    context 'when there is an existing message' do
      subject!(:dashboard_message) do
        described_class.create!(messageable: messageable, message: 'Existing message')
      end

      it 'updates the message' do
        described_class.add_or_insert_message!(messageable, message)
        dashboard_message.reload
        expect(dashboard_message.message).to eq("#{message} Existing message")
      end
    end
  end

  describe '.delete_or_remove_message!' do
    let(:message) { 'There is something wrong with the meters.' }

    context 'when there is no message' do
      it 'does nothing' do
        expect { described_class.delete_or_remove_message!(messageable, message) }.not_to change(described_class, :count)
      end
    end

    context 'when there is an existing message' do
      let(:existing_message) { 'Existing message' }

      subject!(:dashboard_message) do
        described_class.create(messageable: messageable, message: existing_message)
      end

      before do
        described_class.delete_or_remove_message!(messageable, message)
        dashboard_message.reload
      end

      context 'with no matching text' do
        it 'does not change' do
          expect(dashboard_message.message).to eq(existing_message)
        end
      end

      context 'with matching text' do
        let(:existing_message) { "#{message} Existing message" }

        it 'removes the text' do
          expect(dashboard_message.message).to eq('Existing message')
        end
      end
    end
  end
end
