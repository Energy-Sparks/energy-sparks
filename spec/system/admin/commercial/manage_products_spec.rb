require 'rails_helper'

describe 'manage categories' do
  let(:user) { create(:admin) }

  before do
    sign_in(user)
    visit admin_path
  end

  context 'when adding a new product' do
    before do
      click_on 'Products'
      click_on 'New product'
    end

    context 'with valid data' do
      before do
        fill_in 'Name', with: 'Custom product'
        fill_in 'Comments', with: 'Some notes'
        fill_in 'Small school price', with: 200.0
        fill_in 'Large school price', with: 500.0
        fill_in 'Size threshold', with: 300
        fill_in 'Mat price', with: 400.0
        fill_in 'Private account fee', with: 100.0
        fill_in 'Metering fee', with: 10.0
        click_on 'Save'
      end

      it 'creates the model' do
        expect(Commercial::Product.last).to have_attributes(
          name: 'Custom product',
          comments: 'Some notes',
          small_school_price: 200.0,
          large_school_price: 500.0,
          size_threshold: 300,
          mat_price: 400.0,
          private_account_fee: 100.0,
          metering_fee: 10.0,
          created_by: user
        )
      end
    end

    context 'with invalid data' do
      it { expect { click_on 'Save' }.not_to change(Commercial::Product, :count) }

      it 'displays errors' do
        click_on 'Save'
        expect(page).to have_content("Name can't be blank")
      end
    end
  end

  context 'when updating an existing product' do
    let!(:product) { create(:commercial_product) }

    before do
      click_on 'Products'
      click_on 'Edit'
    end

    it { expect(page).to have_content(product.name) }

    context 'with valid data' do
      before do
        fill_in 'Name', with: 'Custom product'
        fill_in 'Comments', with: 'Some notes'
        fill_in 'Small school price', with: 200.0
        fill_in 'Large school price', with: 500.0
        fill_in 'Size threshold', with: 300
        fill_in 'Mat price', with: 400.0
        fill_in 'Private account fee', with: 100.0
        fill_in 'Metering fee', with: 10.0
        click_on 'Save'
      end

      it 'updates the model' do
        expect(product.reload).to have_attributes(
          name: 'Custom product',
          comments: 'Some notes',
          small_school_price: 200.0,
          large_school_price: 500.0,
          size_threshold: 300,
          mat_price: 400.0,
          private_account_fee: 100.0,
          metering_fee: 10.0,
          created_by: product.created_by,
          updated_by: user
        )
      end
    end
  end

  context 'when deleting a product' do
    let!(:product) { create(:commercial_product) }

    before do
      click_on 'Products'
    end

    it { expect { click_on 'Delete' }.to change(Commercial::Product, :count).by(-1) }

    context 'when the product has a contract' do
      before do
        create(:commercial_contract, product:)
        click_on 'Delete'
      end

      it { expect(page).to have_content('Cannot delete a product with contracts') }
    end
  end

  context 'when viewing a product' do
    let!(:product) { create(:commercial_product) }

    before do
      click_on 'Products'
      click_on product.name
    end

    it { expect(page).to have_css('#metadata') }

    it { expect(page).to have_content(product.name) }
    it { expect(page).to have_content(product.comments) }

    context 'when viewing pricing' do
      it { expect(page).to have_content(FormatUnit.format(:£, product.small_school_price)) }
      it { expect(page).to have_content(FormatUnit.format(:£, product.large_school_price)) }
      it { expect(page).to have_content(FormatUnit.format(:£, product.mat_price)) }
      it { expect(page).to have_content(FormatUnit.format(:£, product.private_account_fee)) }
      it { expect(page).to have_content(FormatUnit.format(:£, product.metering_fee)) }
      it { expect(page).to have_content(FormatUnit.format(:pupils, product.size_threshold, :html, false, false)) }
    end

    context 'when viewing contract summary' do
      before do
        create(:commercial_contract, status: :confirmed, product:)
        create_list(:commercial_contract, 2, status: :provisional, product:)
        create_list(:commercial_contract, 4, :future, status: :provisional, product:)
        create_list(:commercial_contract, 3, :historical, status: :provisional, product:)
        create_list(:commercial_contract, 5, :historical, status: :confirmed, product:)
        refresh
      end

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#contract-summary-table' }
        let(:expected_header) do
          [
            ['Category', 'Status', 'Count']
          ]
        end
        let(:expected_rows) do
          [
            ['Current', 'Provisional', '2'],
            ['', 'Confirmed', '1'],
            ['', 'All', '3'],
            ['Future', 'Provisional', '4'],
            ['', 'Confirmed', '0'],
            ['', 'All', '4'],
            ['Historical', 'All', '8']
          ]
        end
      end
    end
  end
end
