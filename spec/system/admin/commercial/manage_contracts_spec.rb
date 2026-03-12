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
        fill_in 'Purchase order number', with: 'PO123'

        set_date('#contract_start_date', '01/01/2026')
        set_date('#contract_end_date', '31/12/2026')

        fill_in 'Agreed school price', with: 525
        select 'Custom', from: 'Licence period'
        fill_in 'Licence years', with: 1.0

        click_on 'Save'
      end

      it 'creates the model' do
        expect(page).to have_content('Contract has been created')
        expect(Commercial::Contract.last).to have_attributes(
          name: 'Custom contract',
          comments: 'Some notes',
          product: product,
          contract_holder: funder,
          licence_period: 'custom',
          licence_years: 1.0,
          number_of_schools: 100,
          purchase_order_number: 'PO123',
          start_date: Date.new(2026, 1, 1),
          end_date: Date.new(2026, 12, 31),
          agreed_school_price: BigDecimal(525),
          created_by: user
        )
      end

      it 'does not create any licences' do
        expect(page).to have_content('Contract has been created')
        expect(Commercial::Contract.last.licences).to be_empty
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

  context 'when updating an existing contract' do
    let!(:contract) { create(:commercial_contract, contract_holder: funder) }
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

      it 'does not create any licences' do
        expect(contract.reload.licences).to be_empty
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

      it { expect(page).to have_content('Cannot delete record because dependent licences exist') }
    end
  end

  context 'when renewing a contract' do
    let!(:contract) do
      create(:commercial_contract,
             contract_holder: create(:school_group),
             agreed_school_price: 600.0,
             invoice_terms: :full,
             licence_period: :contract,
             licence_years: 2,
             number_of_schools: 100)
    end

    let!(:original_licence) do
      create(:commercial_licence, contract:, school_specific_price: 0.0)
    end

    before do
      create(:funder)
      create(:commercial_product, :default_product)
      visit admin_commercial_contract_path(contract)
      click_on 'All contracts'
    end

    context 'when visiting the pre-populated form', :js do
      before { click_on 'Renew' }

      it { expect(page).to have_field('Agreed school price', with: contract.agreed_school_price) }
      it { expect(page).to have_field('Comments', with: "Renewed from #{contract.name}") }
      it { expect(page).to have_select('Invoice terms', selected: 'Full') }
      it { expect(page).to have_select('Licence period', selected: 'Contract') }
      it { expect(page).to have_field('Licence years', with: '2.0') }
      it { expect(page).to have_field('Number of schools', with: contract.number_of_schools) }
      it { expect(page).to have_select('Status', selected: 'Provisional') }

      context 'when submitting with defaults' do
        subject(:renewed_contract) { contract.contract_holder.contracts.by_start_date.last }

        before do
          fill_in('Name', with: 'Renewed contract')
          click_on 'Save'
        end

        it 'creates the contract' do
          expect(page).to have_content('Contract and provisional licences have been created')
          expect(renewed_contract).to have_attributes(
            name: 'Renewed contract',
            comments: "Renewed from #{contract.name}",
            product: contract.product,
            contract_holder: contract.contract_holder,
            licence_period: contract.licence_period,
            licence_years: contract.licence_years,
            number_of_schools: contract.number_of_schools,
            start_date: contract.end_date,
            end_date: contract.end_date + 1.year,
            agreed_school_price: contract.agreed_school_price,
            created_by: user
          )
        end

        it 'creates the licences' do
          expect(page).to have_content('Contract and provisional licences have been created')
          expect(renewed_contract.licences.count).to eq(1)
          expect(renewed_contract.licences.first.school).to eq(original_licence.school)
          expect(renewed_contract.licences.first.school_specific_price).to eq(original_licence.school_specific_price)
        end
      end

      context 'when choosing not to add licences' do
        subject(:renewed_contract) { contract.contract_holder.contracts.by_start_date.last }

        before do
          fill_in('Name', with: 'Renewed contract')
          uncheck('renew_licences')
          click_on 'Save'
        end

        it 'does not create the licences' do
          expect(page).to have_content('Contract has been created')
          expect(renewed_contract.licences.count).to eq(0)
        end
      end
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

    context 'when viewing terms' do
      it {
        expect(page).to have_link(contract.contract_holder.name,
                                     href: polymorphic_path([:admin, contract.contract_holder]))
      }

      it { expect(page).to have_content(contract.contract_holder_type) }
      it { expect(page).to have_content(contract.product.name) }
      it { expect(page).to have_content(contract.start_date) }
      it { expect(page).to have_content(contract.end_date) }
      it { expect(page).to have_content(contract.status.humanize) }
      it { expect(page).to have_content(contract.invoice_terms.humanize) }
      it { expect(page).to have_content(contract.licence_period.humanize) }
      it { expect(page).to have_content(contract.licence_years) }
      it { expect(page).to have_content(contract.number_of_schools) }
      it { expect(page).to have_content(FormatUnit.format(:£, contract.agreed_school_price)) }
      it { expect(page).to have_content(contract.comments) }
    end

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

    context 'when navigating to contract holder page' do
      before { click_on 'All contracts' }

      it { expect(page).to have_content("#{contract.contract_holder.name} Contracts") }

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#contracts-table' }
        let(:expected_header) do
          [
            ['Name', 'Product', 'Start Date', 'End Date', 'Number of Schools', 'Licensed Schools', 'Status', 'Actions']
          ]
        end
        let(:expected_rows) do
          [
            [
              contract.name,
              contract.product.name,
              contract.start_date.iso8601,
              contract.end_date.iso8601,
              contract.number_of_schools.to_s,
              '0',
              contract.status.humanize,
              'Edit Renew Delete'
            ]
          ]
        end
      end
    end
  end
end
