require 'rails_helper'

describe 'TransportType' do

  context "with valid attributes" do
    subject { create :transport_type }
    it { is_expected.to be_valid }
  end

  describe "#safe_destroy" do
    subject! { create :transport_type }

    context "with associated transport survey response" do
      let!(:response) { create(:transport_survey_response, transport_type: subject )}

      it 'raises exception and does not destroy' do
        expect { subject.safe_destroy }
        .to raise_error( EnergySparks::SafeDestroyError, 'Transport type has associated responses')
        .and( not_change{ TransportType.count } )
      end
    end

    context "without an associated transport survey response" do
      it 'does not raise' do
        expect{ subject.safe_destroy }.not_to raise_error
      end
      it "destroys transport type" do
        expect { subject.safe_destroy }.to change { TransportType.count }.from(1).to(0)
      end
    end
  end
end
