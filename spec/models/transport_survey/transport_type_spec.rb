require 'rails_helper'

describe TransportSurvey::TransportType do
  describe 'validations' do
    subject(:transport_type) { build(:transport_type) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_uniqueness_of(:name) }

    [:name, :image, :kg_co2e_per_km, :speed_km_per_hour, :position].each do |attribute|
      it { is_expected.to validate_presence_of(attribute) }
    end

    [:kg_co2e_per_km, :speed_km_per_hour, :position].each do |attribute|
      it { is_expected.to validate_numericality_of(attribute).is_greater_than_or_equal_to(0) }
    end
  end

  describe "#name" do
    subject!(:transport_type) { create(:transport_type) }

    it "has a translatable_type of TransportSurvey::TransportType in the mobility_string_translations table" do
      # This is here as a reminder that #name is a translated field and if the name of the class changes,
      # that it's translatable_type in the database table: mobility_string_translations also needs to change!
      # See: lib/tasks/deployment/20231120150555_fix_transport_type_names.rake
      expect(transport_type.string_translations.first.translatable_type).to eql('TransportSurvey::TransportType')
    end
  end

  describe "#safe_destroy" do
    subject!(:transport_type) { create :transport_type }

    context "with associated transport survey response" do
      let!(:response) { create(:transport_survey_response, transport_type: subject)}

      it 'raises exception and does not destroy' do
        expect { transport_type.safe_destroy }
        .to raise_error(EnergySparks::SafeDestroyError, 'Transport type has associated responses')
        .and(not_change { TransportSurvey::TransportType.count })
      end
    end

    context "without an associated transport survey response" do
      it 'does not raise' do
        expect { transport_type.safe_destroy }.not_to raise_error
      end

      it "destroys transport type" do
        expect { transport_type.safe_destroy }.to change(TransportSurvey::TransportType, :count).from(1).to(0)
      end
    end
  end

  describe "#categories_with_other" do
    it "adds 'other' to categories" do
      expect(TransportSurvey::TransportType.categories_with_other.keys).to eql(TransportSurvey::TransportType.categories.keys + ['other'])
    end

    it "sets other to nil" do
      expect(TransportSurvey::TransportType.categories_with_other['other']).to be_nil
    end
  end

  describe '#tx_slug' do
    subject(:transport_type) { build(:transport_type) }

    it 'produces expected slug' do
      expect(transport_type.tx_slug).to eq("transport_type_#{transport_type.id}")
    end
  end
end
