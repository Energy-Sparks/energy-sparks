require 'rails_helper'

describe 'pricing calculator', :include_application_helper do
  let!(:product) { create(:commercial_product, default_product: true) }

  before do
    sign_in(create(:admin))
    visit admin_commercial_path
  end

  context 'when calculating a product price' do
    before { click_on 'Price calculator' }

    it { expect(page).to have_text('Price Calculator') }
    it { expect(page).to have_select('Product', selected: product.name) }

    context 'with default options' do
      before { click_on 'Calculate' }

      it { expect(page).to have_text("Calculation based on the default pricing defined in #{product.name}") }

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#pricing-table' }
        let(:expected_header) do
          [
            ['', 'Cost']
          ]
        end
        let(:expected_rows) do
          [
            ['Base Price', format_price(product.small_school_price)],
            ['Metering Fee', format_price(0.0)],
            ['Private Account Fee', format_price(0.0)],
            ['Total Price', format_price(product.small_school_price)]
          ]
        end
      end
    end
  end

  context 'when calculating a contract price' do
    let!(:contract) { create(:commercial_contract, agreed_school_price: 500.0) }

    before { click_on 'Price calculator' }

    it { expect(page).to have_text('Price Calculator') }
    it { expect(page).to have_select('Product', selected: product.name) }

    context 'when the contract is selected' do
      before do
        select contract.name, from: 'Contract'
        click_on 'Calculate'
      end

      it {
        expect(page).to have_text("Calculation based on pricing defined in #{contract.name} for the #{contract.product.name} product")
      }

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#pricing-table' }
        let(:expected_header) do
          [
            ['', 'Cost']
          ]
        end
        let(:expected_rows) do
          [
            ['Base Price', format_price(contract.agreed_school_price)],
            ['Metering Fee', format_price(0.0)],
            ['Private Account Fee', format_price(0.0)],
            ['Total Price', format_price(contract.agreed_school_price)]
          ]
        end
      end

      context 'when the contract has custom terms' do
        let!(:contract) do
          create(:commercial_contract, :custom, licence_years: 2.0)
        end

        it { expect(page).to have_text('Custom contract') }
      end
    end
  end
end
