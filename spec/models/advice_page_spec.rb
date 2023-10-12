require 'rails_helper'

describe AdvicePage do
  it 'rejects duplicate keys' do
    AdvicePage.create(key: 'same')
    expect do
      AdvicePage.create(key: 'same')
    end.to raise_error(ActiveRecord::RecordNotUnique)
  end

  describe '#t_fuel_type' do
    it 'returns a translated fuel type used in data warnings etc' do
      advice_page = AdvicePage.create(key: 'same')
      AdvicePage.fuel_types.each_key do |fuel_type|
        advice_page.update(fuel_type: fuel_type)
        if fuel_type == 'solar_pv'
          expect(advice_page.t_fuel_type).to eq(I18n.t("advice_pages.fuel_type.electricity"))
        else
          expect(advice_page.t_fuel_type).to eq(I18n.t("advice_pages.fuel_type.#{fuel_type}"))
        end
      end
    end
  end

  context 'serialising for transifex' do
    context 'when mapping fields' do
      let!(:advice_page) { create(:advice_page, key: "baseload-summary", learn_more: "text here")}
      it 'produces the expected key names' do
        expect(advice_page.tx_attribute_key("learn_more")).to eq "learn_more_html"
      end
      it 'produces the expected tx values, removing trix content wrapper' do
        expect(advice_page.tx_value("learn_more")).to eql("text here")
      end
      it 'produces the expected resource key' do
        expect(advice_page.resource_key).to eq "advice_page_#{advice_page.id}"
      end
      it 'maps all translated fields' do
        data = advice_page.tx_serialise
        expect(data["en"]).to_not be nil
        key = "advice_page_#{advice_page.id}"
        expect(data["en"][key]).to_not be nil
        expect(data["en"][key].keys).to match_array(["learn_more_html"])
      end
      it 'created categories' do
        expect(advice_page.tx_categories).to match_array(["advice_page"])
      end
      it 'overrides default name' do
        expect(advice_page.tx_name).to eq("Advice page #{advice_page.id}")
      end
      it 'fetches status' do
        expect(advice_page.tx_status).to be_nil
        status = TransifexStatus.create_for!(advice_page)
        expect(TransifexStatus.count).to eq 1
        expect(advice_page.tx_status).to eq status
      end
    end
  end
end
