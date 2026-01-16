require 'rails_helper'

describe 'manage contracts' do
  let(:user) { create(:admin) }

  before do
    sign_in(user)
    visit admin_path
  end

  context 'when adding a new contract' do
    let!(:product) { create(:commercial_product, :default_product)}
    let!(:funder) { create(:funder) }

    before do
      click_on 'Contracts'
      click_on 'New contract'
    end

    context 'with valid data', :js do
      before do
        fill_in 'Name', with: 'Custom contract'
        fill_in 'Comments', with: 'Some notes'

        select product.name, from: 'Product'
        choose 'Funder'
        select funder.name, from: 'Contract holder'

        fill_in 'Number of schools', with: 100

        set_date('#contract_start_date', '01/01/2026')
        set_date('#contract_end_date', '31/12/2026')

        fill_in 'Agreed school price', with: 525
        click_on 'Save'
      end

      it 'creates the model' do
        expect(page).to have_content('Contract has been created')
        expect(Commercial::Contract.last).to have_attributes(
          name: 'Custom contract',
          comments: 'Some notes',
          product: product,
          contract_holder: funder,
          number_of_schools: 100,
          start_date: Date.new(2026, 1, 1),
          end_date: Date.new(2026, 12, 31),
          agreed_school_price: BigDecimal(525),
          created_by: user
        )
      end
    end

    context 'with invalid data' do
      it { expect { click_on 'Save' }.not_to change(Commercial::Contract, :count) }

      it 'displays errors' do
        click_on 'Save'
        expect(page).to have_content("Name can't be blank")
      end
    end
  end

  context 'when updating an existing product' do
    let!(:contract) { create(:commercial_contract) }
    let!(:product) { create(:commercial_product, :default_product)}
    let!(:funder) { create(:funder) }

    before do
      click_on 'Contracts'
      click_on 'Edit'
    end

    it { expect(page).to have_content(contract.name) }

    context 'with valid data', :js do
      before do
        fill_in 'Name', with: 'Custom contract'
        fill_in 'Comments', with: 'Some notes'

        select product.name, from: 'Product'
        choose 'Funder'
        select funder.name, from: 'Contract holder'

        fill_in 'Number of schools', with: 100

        set_date('#contract_start_date', '01/01/2026')
        set_date('#contract_end_date', '31/12/2026')

        fill_in 'Agreed school price', with: 525
        click_on 'Save'
      end

      it 'updates the model' do
        expect(page).to have_content('Contract has been updated')
        expect(contract.reload).to have_attributes(
          name: 'Custom contract',
          comments: 'Some notes',
          product: product,
          contract_holder: funder,
          number_of_schools: 100,
          start_date: Date.new(2026, 1, 1),
          end_date: Date.new(2026, 12, 31),
          agreed_school_price: BigDecimal(525),
          created_by: contract.created_by,
          updated_by: user
        )
      end
    end
  end

  context 'when deleting a contract' do
    let!(:contract) { create(:commercial_contract) }

    before do
      click_on 'Contracts'
    end

    it { expect { click_on 'Delete' }.to change(Commercial::Contract, :count).by(-1) }

    context 'when the contract has a licence' do
      before do
        create(:commercial_licence, contract:)
        click_on 'Delete'
      end

      it { expect(page).to have_content('Cannot delete a contract with licences') }
    end
  end

  context 'when viewing a contract' do
    let!(:contract) { create(:commercial_contract) }

    before do
      click_on 'Contracts'
      click_on contract.name
    end

    it { expect(page).to have_css('#metadata') }

    it { expect(page).to have_content(contract.name) }
    it { expect(page).to have_content(contract.comments) }

    context 'when viewing licence summary' do
      before do
        create(:commercial_licence, status: :confirmed, contract:)
        create_list(:commercial_licence, 2, status: :provisional, contract:)
        create_list(:commercial_licence, 4, :future, status: :provisional, contract:)
        create_list(:commercial_licence, 3, :historical, status: :provisional, contract:)
        create_list(:commercial_licence, 5, :historical, status: :confirmed, contract:)
        refresh
      end

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#licence-summary-table' }
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
