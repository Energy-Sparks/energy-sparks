# frozen_string_literal: true

require 'rails_helper'

describe 'manage contracts' do
  let(:user) { create(:admin) }

  before do
    sign_in(user)
    visit admin_commercial_path
  end

  context 'when adding a new contract' do
    let!(:product) { create(:commercial_product, :default_product) }
    let!(:funder) { create(:funder) }

    before do
      click_on 'New contract'
    end

    it { expect(page).to have_field('Contract holder') }
    it { expect(page).to have_field('Product') }

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

  context 'when adding a new contract for a contract holder' do
    let!(:product) { create(:commercial_product, :default_product) }
    let(:contract_holder) { create(:school_group) }

    before do
      visit admin_school_group_contracts_path(contract_holder)
      click_on 'New contract'
    end

    it 'initialises the form correctly' do
      expect(page).to have_content("Create a new contract for #{contract_holder.name}")
    end

    it { expect(page).to have_no_field('Contract holder') }

    context 'with valid data', :js do
      before do
        fill_in 'Name', with: 'Custom contract'
        fill_in 'Comments', with: 'Some notes'

        select product.name, from: 'Product'
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
          contract_holder: contract_holder,
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
  end

  context 'when updating an existing contract' do
    let!(:contract) { create(:commercial_contract, contract_holder: funder) }
    let!(:funder) { create(:funder) }

    before do
      click_on 'All Contracts'
    end

    context 'when the contract is editable' do
      before { click_on 'Edit' }

      it { expect(page).to have_content(contract.name) }

      it {
        expect(page).to have_content(
          'Any changes made to the start and end dates for this contract will be automatically applied to all licences'
        )
      }

      it { expect(page).to have_no_field('Contract holder') }
      it { expect(page).to have_no_field('Product') }
      it { expect(page).to have_no_select('Invoice terms') }
      it { expect(page).to have_no_select('Licence period') }
      it { expect(page).to have_no_field('Licence years') }

      context 'with valid data', :js do
        before do
          fill_in 'Name', with: 'Custom contract'
          fill_in 'Comments', with: 'Some notes'
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
            product: contract.product,
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

    context 'when there are licences' do
      let!(:licence) { create(:commercial_licence, contract:) }

      before { click_on 'Edit' }

      context 'when making changes to be cascaded', :js do
        before do
          select 'Confirmed', from: 'Status'
          set_date('#contract_start_date', '01/01/2026')
          set_date('#contract_end_date', '31/12/2026')
          click_on 'Save'
        end

        it 'updates the model' do
          expect(page).to have_content('Contract and licences have been updated')
          expect(licence.reload).to have_attributes(
            start_date: Date.new(2026, 1, 1),
            end_date: Date.new(2026, 12, 31),
            status: 'confirmed',
            updated_by: user
          )
        end
      end
    end

    context 'when the contract has invoiced licences' do
      before do
        create(:commercial_licence, contract:, status: :invoiced)
        click_on 'Edit'
      end

      it { expect(page).to have_content(contract.name) }

      it {
        expect(page).to have_content('One or more licences associated with this contract have already been invoiced')
      }

      it { expect(page).to have_no_field('Contract holder') }
      it { expect(page).to have_no_field('Product') }
      it { expect(page).to have_no_select('Invoice terms') }
      it { expect(page).to have_no_select('Licence period') }
      it { expect(page).to have_no_field('Licence years') }
    end
  end

  context 'when deleting a contract' do
    let!(:contract) { create(:commercial_contract) }

    before do
      click_on 'All Contracts'
    end

    it { expect { click_on 'Delete' }.to change(Commercial::Contract, :count).by(-1) }

    context 'when the contract has licences' do
      context 'with a provisional status' do
        before do
          create(:commercial_licence, contract:, status: :provisional)
        end

        it { expect { click_on 'Delete' }.to change(Commercial::Contract, :count).by(-1) }
      end

      context 'with an invoiced status' do
        before do
          create(:commercial_licence, contract:, status: :invoiced)
        end

        it { expect { click_on 'Delete' }.not_to change(Commercial::Contract, :count) }
      end
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
            start_date: contract.end_date + 1.day,
            end_date: contract.end_date.next_year,
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
    let!(:contract) do
      create(:commercial_contract,
             agreed_school_price: 600.0)
    end

    before do
      click_on 'All Contracts'
      click_on contract.name
    end

    it { expect(page).to have_css('#metadata') }

    it { expect(page).to have_content(contract.name) }
    it { expect(page).to have_content(contract.comments) }

    context 'when viewing terms' do
      it {
        expect(page).to have_link(contract.contract_holder.name,
                                  href: polymorphic_path([:admin, contract.contract_holder, :contracts]))
      }

      it { expect(page).to have_content(contract.contract_holder_type) }
      it { expect(page).to have_content(contract.product.name) }
      it { expect(page).to have_content(contract.start_date.to_fs(:es_short)) }
      it { expect(page).to have_content(contract.end_date.to_fs(:es_short)) }
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
        create_list(:commercial_licence, 3, :expired, status: :provisional, contract:)
        create_list(:commercial_licence, 5, :expired, status: :confirmed, contract:)
        refresh
      end

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#licence-summary-table' }
        let(:expected_header) do
          [
            %w[Category Status Count]
          ]
        end
        let(:expected_rows) do
          [
            ['Current', 'Provisional', '2'],
            ['', 'Confirmed', '1'],
            ['', 'Pending invoice', '0'],
            ['', 'Invoiced', '0'],
            ['', 'All', '3'],
            ['Future', 'Provisional', '4'],
            ['', 'Confirmed', '0'],
            ['', 'Pending invoice', '0'],
            ['', 'Invoiced', '0'],
            ['', 'All', '4'],
            ['Expired', 'Provisional', '3'],
            ['', 'Confirmed', '5'],
            ['', 'Pending invoice', '0'],
            ['', 'Invoiced', '0'],
            ['', 'All', '8']
          ]
        end
      end
    end

    context 'when viewing financial summary' do
      before do
        create(:commercial_licence, status: :confirmed, contract:)
        refresh
      end

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#total-contract-value' }
        let(:expected_header) do
          [
            %w[Charge Cost]
          ]
        end
        let(:expected_rows) do
          [
            ['Base price', '£600'],
            ['Metering fees', '0p'],
            ['Private account fees', '0p'],
            ['Total', '£600']
          ]
        end
      end
    end

    context 'when viewing contract value' do
      before do
        create(:commercial_licence, status: :confirmed, contract:)
        refresh
      end

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false, tfoot: true do
        let(:table_id) { '#per-school-fees' }
        let(:expected_header) do
          [
            ['School Group', 'School', 'Base price', 'Metering fee', 'Private account fee', 'Total']
          ]
        end
        let(:expected_rows) do
          [
            ['', contract.schools.first.name, '£600', '0p', '0p', '£600']
          ]
        end
        let(:expected_footer_rows) do
          [
            ['', '', '£600', '0p', '0p', '£600']
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
              contract.start_date.to_fs(:es_short),
              contract.end_date.to_fs(:es_short),
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

  context 'when viewing contract lists' do
    context 'with current' do
      let!(:contract) { create(:commercial_contract) }

      before { click_on 'Current Contracts' }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_content(contract.name)
        end
      end
    end

    context 'with expired' do
      let!(:contract) { create(:commercial_contract, :expired) }

      before { click_on 'Expired Contracts' }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_content(contract.name)
        end
      end
    end

    context 'with expiring' do
      let!(:contract) { create(:commercial_contract, end_date: Time.zone.today + 1) }

      before { click_on 'Expiring Contracts' }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_content(contract.name)
        end
      end
    end

    context 'with recent' do
      let!(:contract) { create(:commercial_contract) }

      before { click_on 'Recently Added Contracts' }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_content(contract.name)
        end
      end
    end

    context 'with provisional' do
      let!(:contract) { create(:commercial_contract, status: :provisional) }

      before { click_on 'Provisional Contracts' }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_content(contract.name)
        end
      end
    end

    context 'with future' do
      let!(:contract) { create(:commercial_contract, :future) }

      before { click_on 'Future Contracts' }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_content(contract.name)
        end
      end
    end
  end
end
