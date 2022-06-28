require 'rails_helper'

describe 'InterventionType' do

  subject { create :intervention_type }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'is invalid with invalid attributes' do
    type = build :intervention_type, score: -1
    expect( type ).to_not be_valid
    expect( type.errors[:score] ).to include('must be greater than or equal to 0')
  end

  context 'when translations are being applied' do
    let(:old_name) { 'old-name' }
    let(:new_name) { 'new-name' }

    it 'updates original name so search still works' do
      intervention_type = create(:intervention_type, name: old_name)
      expect(InterventionType.search(new_name)).to eq([])

      intervention_type.update(name: new_name)

      expect(intervention_type.attributes['name']).to eq(new_name)
      expect(InterventionType.search(new_name)).to eq([intervention_type])
    end
  end

  context 'search by query term' do
    it 'finds interventions by name' do
      intervention_type_1 = create(:intervention_type, name: 'foo')
      intervention_type_2 = create(:intervention_type, name: 'bar')

      expect(InterventionType.search('foo')).to eq([intervention_type_1])
      expect(InterventionType.search('bar')).to eq([intervention_type_2])
    end

    it 'applies search variants' do
      intervention_type_1 = create(:intervention_type, name: 'time')
      intervention_type_2 = create(:intervention_type, name: 'timing')

      expect(InterventionType.search('timing')).to eq([intervention_type_1, intervention_type_2])
    end
  end

  context 'serialising for transifex' do
    context 'when mapping fields' do
      let!(:intervention_type) { create(:intervention_type, name: "My intervention", description: "description", summary: "summary")}
      it 'produces the expected key names' do
        expect(intervention_type.tx_attribute_key("name")).to eq "name"
        expect(intervention_type.tx_attribute_key("summary")).to eq "summary"
        expect(intervention_type.tx_attribute_key("description")).to eq "description_html"
        expect(intervention_type.tx_attribute_key("download_links")).to eq "download_links_html"
      end
      it 'produces the expected tx values, removing trix content wrapper' do
        expect(intervention_type.tx_value("name")).to eql intervention_type.name
        expect(intervention_type.tx_value("description")).to eql("description")
      end
      it 'produces the expected resource key' do
        expect(intervention_type.resource_key).to eq "intervention_type_#{intervention_type.id}"
      end
      it 'maps all translated fields' do
        data = intervention_type.tx_serialise
        expect(data["en"]).to_not be nil
        key = "intervention_type_#{intervention_type.id}"
        expect(data["en"][key]).to_not be nil
        expect(data["en"][key].keys).to match_array(["name", "summary", "description_html", "download_links_html"])
      end
      it 'created categories' do
        expect(intervention_type.tx_categories).to match_array(["intervention_type"])
      end
      it 'overrides default name' do
        expect(intervention_type.tx_name).to eq("My intervention")
      end
      it 'fetches status' do
        expect(intervention_type.tx_status).to be_nil
        status = TransifexStatus.create_for!(intervention_type)
        expect(TransifexStatus.count).to eq 1
        expect(intervention_type.tx_status).to eq status
      end
    end
  end
  context 'when updating from transifex' do
    let(:resource_key) { "intervention_type_#{subject.id}" }
    let(:name) { subject.name }
    let(:summary) { subject.summary }
    let(:description) { subject.description }
    let(:download_links) { subject.download_links }
    let(:data) { {
      "cy" => {
        resource_key => {
          "name" => "Welsh name",
          "summary" => "The Welsh summary",
          "description_html" => "The Welsh description",
          "download_links_html" => "Links for Welsh <a href=\"google.com\">Google</a>"
        }
      }
    }
    }
    before(:each) do
      subject.tx_update(data, :cy)
      subject.reload
    end
    it 'updates simple fields' do
      expect(subject.name).to eq name
      expect(subject.name_cy).to eq "Welsh name"
      expect(subject.summary_cy).to eq "The Welsh summary"
    end
    it 'updates HTML fields' do
      expect(subject.description).to eq description
      expect(subject.description_cy.to_s).to eql("<div class=\"trix-content\">\n  The Welsh description\n</div>\n")
      expect(subject.download_links_cy.to_s).to eql("<div class=\"trix-content\">\n  Links for Welsh <a href=\"google.com\">Google</a>\n</div>\n")
    end
  end
end
