require 'rails_helper'

describe Transifex::Synchroniser, type: :service do
  let(:activity_type) { create(:activity_type) }
  let(:service)       { Transifex::Synchroniser.new(activity_type, :cy) }
  let(:resource_key)  { activity_type.resource_key }

  let(:client)        { double('transifex-client') }

  before(:each) do
    allow(Transifex::Service).to receive(:create_client).and_return(client)
  end

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
      activity_type.update!(updated_at: Time.zone.today - 1)
    end
    context 'not updated' do
      let(:last_push) { Time.zone.today }
      it 'returns false' do
        expect(service.updated_since_last_pushed?).to be false
      end
    end
    context 'updated' do
      let(:last_push) { Time.zone.today - 2 }
      it 'returns true' do
        expect(service.updated_since_last_pushed?).to be true
      end
    end
  end

  describe '#translations_updated_since_last_pull?' do
    let(:last_pull) { Time.zone.today - 1 }
    let!(:status) { create(:transifex_status, record_type: "ActivityType", record_id: activity_type.id, tx_last_pull: last_pull)}
    before(:each) do
      allow_any_instance_of(Transifex::Service).to receive(:last_reviewed).and_return(last_reviewed)
    end
    context 'not updated' do
      let(:last_reviewed) { Time.zone.today - 2 }
      it 'returns false' do
        expect(service.translations_updated_since_last_pull?).to be false
      end
    end
    context 'updated' do
      let(:last_reviewed) { Time.zone.today }
      it 'returns true' do
        expect(service.translations_updated_since_last_pull?).to be true
      end
    end
    context 'when last pulled not set yet' do
      let(:last_pull) { nil }
      context 'but not reviewed yet' do
        let(:last_reviewed) { nil }
        it 'returns false' do
          expect(service.translations_updated_since_last_pull?).to be false
        end
      end
      context 'and has been reviewed' do
        let(:last_reviewed) { Time.zone.today }
        it 'returns true' do
          expect(service.translations_updated_since_last_pull?).to be true
        end
      end
    end
  end

  describe '#pull' do
    let(:tx_last_pulled) { nil }
    let!(:status) { create(:transifex_status, record_type: "ActivityType", record_id: activity_type.id, tx_last_pull: tx_last_pulled)}

    context 'when not created' do
      before do
        allow_any_instance_of(Transifex::Service).to receive(:created_in_transifex?).and_return(false)
      end
      it 'does not do a pull' do
        expect(service.pull).to be false
      end
    end

    context 'when not reviewed' do
      before(:each) do
        allow_any_instance_of(Transifex::Service).to receive(:created_in_transifex?).and_return(true)
        allow_any_instance_of(Transifex::Service).to receive(:reviews_completed?).and_return(false)
      end
      it 'does not do a pull' do
        expect(service.pull).to be false
      end
    end

    context 'when translations are reviewed' do
      let(:resource_key) { activity_type.resource_key }
      let(:translations) do
        {
          "cy" => {
            resource_key => {
              "name" => "Welsh name"
            }
           }
         }
      end
      before(:each) do
        allow_any_instance_of(Transifex::Service).to receive(:created_in_transifex?).and_return(true)
        allow_any_instance_of(Transifex::Service).to receive(:reviews_completed?).and_return(true)
        expect_any_instance_of(Transifex::Service).to receive(:pull).and_return(translations)
      end

      it 'pulls the data' do
        expect(status.tx_last_pull).to be_nil
        expect(service.pull).to be true
        status.reload
        expect(status.tx_last_pull).to_not be_nil
      end

      it 'updates the record' do
        expect(service.pull).to be true
        activity_type.reload
        expect(activity_type.name_cy).to eql("Welsh name")
      end
    end

    context 'when not changed in transifex' do
      let(:tx_last_pulled) { Time.zone.now }
      before(:each) do
        allow_any_instance_of(Transifex::Service).to receive(:created_in_transifex?).and_return(true)
        allow_any_instance_of(Transifex::Service).to receive(:reviews_completed?).and_return(true)
        allow_any_instance_of(Transifex::Service).to receive(:last_reviewed).and_return(Time.zone.today - 1)
      end

      it 'doesnt do a pull' do
        expect(service.pull).to be false
      end
    end

    context 'when changed in transifex' do
      let(:yesterday)      { Time.zone.today - 1 }
      let(:tx_last_pulled) { yesterday }
      let(:translations) do
        {
          "cy" => {
            resource_key => { "name": "Updated" }
           }
         }
      end
      before(:each) do
        allow_any_instance_of(Transifex::Service).to receive(:created_in_transifex?).and_return(true)
        allow_any_instance_of(Transifex::Service).to receive(:reviews_completed?).and_return(true)
        allow_any_instance_of(Transifex::Service).to receive(:last_reviewed).and_return(Time.zone.now)
        expect_any_instance_of(Transifex::Service).to receive(:pull).and_return(translations)
      end

      it 'does a pull' do
        expect(service.pull).to be true
        status.reload
        expect(status.tx_last_pull).to_not eq yesterday
      end

      it 'wont push after that pull' do
        status.update!(tx_last_push: yesterday)
        expect(service.pull).to be true
        expect(service.push).to be false
      end
    end
  end

  describe '#push' do
    let(:tx_last_pushed) { nil }
    let!(:status) { create(:transifex_status, record_type: "ActivityType", record_id: activity_type.id, tx_last_push: tx_last_pushed)}

    context 'when not created' do
      before(:each) do
        allow_any_instance_of(Transifex::Service).to receive(:created_in_transifex?).and_return(false)
        expect_any_instance_of(Transifex::Service).to receive(:create_resource).and_return true
        expect_any_instance_of(Transifex::Service).to receive(:push).and_return true
      end
      it 'creates the resource and pushes' do
        expect(service.push).to be true
        status.reload
        expect(status.tx_last_push).to_not be_nil
      end
    end
    context 'when there are local changes' do
      let(:yesterday)      { Time.zone.today - 1 }
      let(:tx_last_pushed) { yesterday }
      before(:each) do
        allow_any_instance_of(Transifex::Service).to receive(:created_in_transifex?).and_return(true)
        expect_any_instance_of(Transifex::Service).to receive(:push).and_return true
      end

      it 'pushes the data' do
        #activity type updated_at will be Time.zone.now
        #so should push as tx dates are yesterday
        expect(service.push).to be true
        status.reload
        expect(status.tx_last_push).to_not eq yesterday
      end
    end
    context 'when there are no recent changes' do
      let(:tx_last_pushed) { Time.zone.now }
      before(:each) do
        allow_any_instance_of(Transifex::Service).to receive(:created_in_transifex?).and_return(true)
      end
      it 'does not push' do
        expect(service.push).to be false
      end
    end
  end
end
