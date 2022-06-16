require 'rails_helper'

describe Transifex::Synchroniser, type: :service do

  let(:activity_type) { create(:activity_type) }
  let(:service)     { Transifex::Synchroniser.new(activity_type) }

  describe '#last_pushed' do
    context 'and no status' do
      it 'returns nil' do
        expect(service.last_pushed).to be_nil
      end
    end
    context 'and never pushed' do
      let!(:status) { TransifexStatus.create_for!(activity_type) }
      it 'returns nil' do
        expect(service.last_pushed).to be_nil
      end
    end
    context 'and was pushed' do
      let!(:status) { create(:transifex_status, record_type: "ActivityType", record_id: activity_type.id)}
      it 'returns the date' do
        expect(service.last_pushed).to eq status.tx_last_push
      end
    end
  end

  describe '#last_pulled' do
    context 'and no status' do
      it 'returns nil' do
        expect(service.last_pulled).to be_nil
      end
    end
    context 'and never pushed' do
      let!(:status) { TransifexStatus.create_for!(activity_type) }
      it 'returns nil' do
        expect(service.last_pulled).to be_nil
      end
    end
    context 'and was pushed' do
      let!(:status) { create(:transifex_status, record_type: "ActivityType", record_id: activity_type.id)}
      it 'returns the date' do
        expect(service.last_pulled).to eq status.tx_last_push
      end
    end
  end

  describe '#created_in_transifex?' do
    context 'and no status' do
      it 'returns false' do
        expect(service.created_in_transifex?).to be false
      end
    end
    context 'and not created' do
      let!(:status) { create(:transifex_status, record_type: "ActivityType", record_id: activity_type.id, tx_created_at: nil)}
      it 'returns false' do
        expect(service.created_in_transifex?).to be false
      end
    end
    context 'and created' do
      let!(:status) { create(:transifex_status, record_type: "ActivityType", record_id: activity_type.id)}
      it 'returns the date' do
        expect(service.created_in_transifex?).to eq true
      end
    end
  end

  describe '#reviews_completed?' do
    context 'not completed' do
      before(:each) do
        allow_any_instance_of(Transifex::Service).to receive(:reviews_completed?).and_return(false)
      end
      it 'returns false' do
        expect(service.reviews_completed?).to be false
      end
    end
    context 'completed' do
      before(:each) do
        allow_any_instance_of(Transifex::Service).to receive(:reviews_completed?).and_return(true)
      end
      it 'returns true' do
        expect(service.reviews_completed?).to be true
      end
    end
  end

  describe '#updated_since_last_pushed?' do
    let!(:status) { create(:transifex_status, record_type: "ActivityType", record_id: activity_type.id, tx_last_push: last_push)}
    before(:each) do
      activity_type.update!(updated_at: Date.today - 1)
    end
    context 'not updated' do
      let(:last_push) { Date.today }
      it 'returns false' do
        expect(service.updated_since_last_pushed?).to be false
      end
    end
    context 'updated' do
      let(:last_push) { Date.today - 2 }
      it 'returns true' do
        expect(service.updated_since_last_pushed?).to be true
      end
    end
  end

  describe '#translations_updated_since_last_pull?' do
    let(:last_pull) { Date.today - 1 }
    let!(:status) { create(:transifex_status, record_type: "ActivityType", record_id: activity_type.id, tx_last_pull: last_pull)}
    before(:each) do
      allow_any_instance_of(Transifex::Service).to receive(:last_reviewed).and_return(last_reviewed)
    end
    context 'not updated' do
      let(:last_reviewed) { Date.today - 2 }
      it 'returns false' do
        expect(service.translations_updated_since_last_pull?).to be false
      end
    end
    context 'updated' do
      let(:last_reviewed) { Date.today }
      it 'returns true' do
        expect(service.translations_updated_since_last_pull?).to be true
      end
    end
  end

  describe '#pull' do
    context 'when not reviewed' do
      it 'does not do a pull'
    end

    context 'when reviewed' do
      it 'pulls the data'
      it 'updated the record'
    end

    context 'when no changes in transifex' do
      it 'does not do a pull'
    end
  end

  describe '#push' do
    context 'when not created' do
      it 'pushes the data'
    end
    context 'when there are local changes' do
      it 'pushes the data'
    end
    context 'when there are no recent changes' do
      it 'does not push'
    end
  end

  describe '#synchronise' do
    it 'does a pull then a push'
    it 'does not pull if just pushed'
    it 'returns some stats?'
  end

end
