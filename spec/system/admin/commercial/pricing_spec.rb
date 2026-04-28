require 'rails_helper'

describe 'pricing calculator' do
  include AdvicePageHelper

  let!(:product) { create(:commercial_product, default_product: true) }

  before do
    sign_in(create(:admin))
    visit admin_commercial_path
  end

  context 'when calculating a product price' do
    before { click_on 'Price calculator' }

    it { expect(page).to have_content('Price Calculator') }
    it { expect(page).to have_select('Product', selected: product.name) }

    context 'with default options' do
      before { click_on 'Calculate' }

      it { expect(page).to have_content("Calculation based on the default pricing defined in #{product.name}") }

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#pricing-table' }
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

    before { click_on 'Price calculator' }

    it { expect(page).to have_content('Price Calculator') }
    it { expect(page).to have_select('Product', selected: product.name) }

    context 'when the contract is selected' do
      before do
        select contract.name, from: 'Contract'
        click_on 'Calculate'
      end

      it { expect(page).to have_content("Calculation based on pricing defined in #{contract.name} for the #{contract.product.name} product") }

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#pricing-table' }
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

      context 'when the contract has custom terms' do
        let!(:contract) do
          create(:commercial_contract,
                 invoice_terms: :pro_rata,
                 licence_period: :custom,
                 licence_years: 2.0)
        end

        it { expect(page).to have_content('Pro-rata contract') }
        it { expect(page).to have_content('Custom contract') }
      end
    end
  end
end
