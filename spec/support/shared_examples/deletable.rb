# frozen_string_literal: true

RSpec.shared_examples 'a deletable record' do |error_message, using_association: nil|
  describe 'deletable' do
    before { record }

    context 'when the record is not in use' do
      it { expect(record).to be_deletable }

      it 'deletes the record' do
        expect { record.destroy }.to change(described_class, :count).by(-1)
      end
    end

    context 'when the record is in use' do
      before { record_in_use }

      it { expect(record).not_to be_deletable }

      it 'does not delete the record' do
        expect { record.destroy }.not_to change(described_class, :count)
      end

      it 'explains why the record cannot be deleted' do
        record.destroy

        expect(record.errors.full_messages).to include(error_message)
      end

      it 'leaves the records using it in place', if: using_association do
        record.destroy

        expect(record_in_use.reload.public_send(using_association)).to include(record)
      end
    end
  end
end
