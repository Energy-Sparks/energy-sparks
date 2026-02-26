require 'rails_helper'

describe 'pricing calculator' do
  include AdvicePageHelper

  let!(:product) { create(:commercial_product, default_product: true) }

  before do
    sign_in(create(:admin))
    visit admin_path
  end

  context 'when calculating a product price' do
    before { click_on 'Pricing' }

    it { expect(page).to have_content('Price Calculator') }
    it { expect(page).to have_select('Product', selected: product.name) }

    context 'with default options' do
      before { click_on 'Calculate' }

      it { expect(page).to have_content("Calculation based on pricing specified in #{product.name}") }

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#pricing' }
        let(:expected_header) do
          [
            ['', 'Cost']
          ]
        end
        let(:expected_rows) do
          [
            ['Base Price', format_unit(product.small_school_price, :£, true, :ks2, :text)],
            ['Metering Fee', format_unit(0.0, :£, true, :ks2, :text)],
            ['Private Account Fee', format_unit(0.0, :£, true, :ks2, :text)],
            ['Total Price', format_unit(product.small_school_price, :£, true, :ks2, :text)]
          ]
        end
      end
    end
  end

  context 'when calculating a contract price' do
    let!(:contract) { create(:commercial_contract, agreed_school_price: 500.0) }

    before { click_on 'Pricing' }

    it { expect(page).to have_content('Price Calculator') }
    it { expect(page).to have_select('Product', selected: product.name) }

    context 'when the contract is selected' do
      before do
        select contract.name, from: 'Contract'
        click_on 'Calculate'
      end

      it { expect(page).to have_content("Calculation based on pricing specified in #{contract.name} for the #{contract.product.name} product") }

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#pricing' }
        let(:expected_header) do
          [
            ['', 'Cost']
          ]
        end
        let(:expected_rows) do
          [
            ['Base Price', format_unit(contract.agreed_school_price, :£, true, :ks2, :text)],
            ['Metering Fee', format_unit(0.0, :£, true, :ks2, :text)],
            ['Private Account Fee', format_unit(0.0, :£, true, :ks2, :text)],
            ['Total Price', format_unit(contract.agreed_school_price, :£, true, :ks2, :text)]
          ]
        end
      end
    end
  end

  context 'when calculating a school price' do
    let!(:school) { create(:school) }
    let!(:licence) { create(:commercial_licence, school:, school_specific_price: 1000) }
    let(:contract) { licence.contract }

    before do
      visit admin_commercial_pricing_path(pricing: { school_id: school.id })
    end

    it { expect(page).to have_content("This page allows you to use the built-in price calculator to generate pricing for #{school.name}.")}

    context 'with default options' do
      before { click_on 'Calculate' }

      it { expect(page).to have_content("Calculation based on pricing specified in #{contract.name} for the #{contract.product.name} product") }
      it { expect(page).to have_content('Existing school pricing') }

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#pricing' }
        let(:expected_header) do
          [
            ['', 'Cost']
          ]
        end
        let(:expected_rows) do
          [
            ['Base Price', format_unit(contract.product.small_school_price, :£, true, :ks2, :text)],
            ['Metering Fee', format_unit(0.0, :£, true, :ks2, :text)],
            ['Private Account Fee', format_unit(0.0, :£, true, :ks2, :text)],
            ['Total Price', format_unit(contract.product.small_school_price, :£, true, :ks2, :text)]
          ]
        end
      end

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#school-pricing' }
        let(:expected_header) do
          [
            ['', 'Cost']
          ]
        end
        let(:expected_rows) do
          [
            ['Base Price', format_unit(licence.school_specific_price, :£, true, :ks2, :text)],
            ['Metering Fee', format_unit(0.0, :£, true, :ks2, :text)],
            ['Private Account Fee', format_unit(0.0, :£, true, :ks2, :text)],
            ['Total Price', format_unit(licence.school_specific_price, :£, true, :ks2, :text)]
          ]
        end
      end
    end
  end
end
