require 'rails_helper'

describe EquivalenceTypeContentVersion do
  context 'serialising for transifex' do
    let(:equivalence_type) { create(:equivalence_type) }
    let!(:content_version) { EquivalenceTypeContentVersion.create(equivalence_type: equivalence_type, equivalence: 'some content with {{position}}') }
    let!(:prior_content_version) { EquivalenceTypeContentVersion.create(equivalence_type: equivalence_type, equivalence: 'replaced', replaced_by: content_version) }

    context 'when fetching records for sync' do
      it 'includes only current content records' do
        expect(EquivalenceTypeContentVersion.tx_resources).to match_array([content_version])
      end
    end

    context 'when serialising fields' do
      it 'includes equivalance' do
        data = content_version.tx_serialise
        key = data["en"].keys.first
        expect(data["en"][key].keys).to match_array(["equivalence_html"])
      end
    end

    context 'when mapping fields' do
      it 'produces the expected resource key' do
        expect(content_version.resource_key).to eq "equivalence_type_content_version_#{equivalence_type.id}"
      end

      it 'produces the expected key names' do
        expect(content_version.tx_attribute_key("equivalence")).to eq "equivalence_html"
      end

      it 'produces the expected tx values, removing trix content wrapper' do
        expect(content_version.tx_value("equivalence")).to eql "some content with %{tx_var_position}"
      end

      it 'created categories' do
        expect(content_version.tx_categories).to match_array(["equivalence_type"])
      end

      it 'overrides default name' do
        expect(content_version.tx_name).to eq("Equivalence type content version #{equivalence_type.id}")
      end

      it 'fetches status' do
        expect(content_version.tx_status).to be_nil
        status = TransifexStatus.create_for!(content_version)
        expect(TransifexStatus.count).to eq 1
        expect(content_version.tx_status).to eq status
      end
    end
  end
end
