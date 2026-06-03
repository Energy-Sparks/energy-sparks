# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Issues::BulkUpdate do
  let(:issueable) { create(:school) }
  let(:user_from) { create(:admin) }
  let(:user_to) { create(:admin) }
  let(:updated_by) { create(:admin) }

  subject(:service) do
    described_class.new(
      issueable: issueable,
      user_from: user_from&.id,
      user_to: user_to&.id,
      updated_by: updated_by&.id
    )
  end

  describe '#perform' do
    context 'when issueable is missing' do
      let(:issueable) { nil }

      it 'raises error' do
        expect { service.perform }.to raise_error(Issues::BulkError) { |e|
          expect(e.messages).to eq(['Issueable is required'])
        }
      end
    end

    context 'when user_from or user_to is blank' do
      let(:user_from) { nil }

      it 'raises error' do
        expect { service.perform }.to raise_error(Issues::BulkError) { |e|
          expect(e.messages).to eq(['Both current and new admin users are required'])
        }
      end
    end

    context 'when user_from equals user_to' do
      let(:user_to) { user_from }

      it 'raises error' do
        expect { service.perform }.to raise_error(Issues::BulkError) { |e|
          expect(e.messages).to eq(["Current and new admin users can't be the same"])
        }
      end
    end

    context 'when valid' do
      let!(:issues) { create_list(:issue, 3, issueable: issueable, owned_by: user_from) }
      let!(:other_owner) { create(:issue, issueable: issueable, owned_by: create(:user)) }
      let!(:other_issueable) { create(:issue, issueable: create(:school), owned_by: user_from) }

      subject(:bulk_update) { service.perform }

      before do
        travel_to(1.day.ago)
        bulk_update
      end

      it 'returns the number of updated records' do
        expect(bulk_update).to eq(3)
      end

      it 'reassigns ownership for matching issues' do
        issues.each do |issue|
          expect(issue.reload.owned_by_id).to eq(user_to.id)
        end
      end

      it 'sets updated_by for updated issues' do
        issues.each do |issue|
          expect(issue.reload.updated_by_id).to eq(updated_by.id)
        end
      end

      it 'sets updated_at to current time' do
        issues.each do |issue|
          expect(issue.reload.updated_at).to eq(Time.current)
        end
      end

      it 'does not update issues with a different owner' do
        expect(other_owner.reload.owned_by_id).not_to eq(user_to.id)
      end

      it 'does not update issues from a different issueable' do
        expect(other_issueable.reload.owned_by_id).to eq(user_from.id)
      end
    end

    context 'when multiple validation errors exist' do
      let(:issueable) { nil }
      let(:user_from) { nil }
      let(:user_to)   { nil }

      it 'raises BulkError with all messages' do
        expect { service.perform }.to raise_error(Issues::BulkError) { |e|
          expect(e.messages).to contain_exactly(
            'Issueable is required',
            'Both current and new admin users are required'
          )
        }
      end
    end
  end
end
