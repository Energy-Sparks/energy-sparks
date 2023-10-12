require 'rails_helper'

describe TransportType do
  describe 'validations' do
    subject { build(:transport_type) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_uniqueness_of(:name) }

    [:name, :image, :kg_co2e_per_km, :speed_km_per_hour, :position].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end

    [:kg_co2e_per_km, :speed_km_per_hour, :position].each do |attribute|
      it { is_expected.to validate_numericality_of(attribute).is_greater_than_or_equal_to(0) }
    end
  end

  describe "#safe_destroy" do
    subject! { create :transport_type }

    context "with associated transport survey response" do
      let!(:response) { create(:transport_survey_response, transport_type: subject)}

      it 'raises exception and does not destroy' do
        expect { subject.safe_destroy }
        .to raise_error(EnergySparks::SafeDestroyError, 'Transport type has associated responses')
        .and(not_change { TransportType.count })
      end
    end

    context "without an associated transport survey response" do
      it 'does not raise' do
        expect { subject.safe_destroy }.not_to raise_error
      end
      it "destroys transport type" do
        expect { subject.safe_destroy }.to change { TransportType.count }.from(1).to(0)
      end
    end
  end

  describe "#categories_with_other" do
    it "adds 'other' to categories" do
      expect(TransportType.categories_with_other.keys).to eql(TransportType.categories.keys + ['other'])
    end
    it "sets other to nil" do
      expect(TransportType.categories_with_other['other']).to be_nil
    end
  end
end
