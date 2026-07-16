# frozen_string_literal: true

require 'rails_helper'

shared_examples 'a filtered contract list' do
  let(:filter_date) { nil }

  it { expect(page).to have_field(:date) }

  context 'when applying a filter', :js do
    before do
      set_date('#filters_date', filter_date)
      click_on 'Filter'
    end

    it 'filters the view' do
      within('#contracts-table') do
        expect(page).to have_no_text(filtered_contract.name)
      end
    end
  end
end

shared_examples 'it shows the common contract fields' do
  it { expect(page).to have_field('Name') }
  it { expect(page).to have_field('Comments') }
  it { expect(page).to have_field('Contract holder') }
  it { expect(page).to have_field('Product') }
end

shared_examples 'it shows the fields for a non-custom contract' do
  it { expect(page).to have_no_field('Licence period') }
  it { expect(page).to have_no_field('Licence years') }
end

shared_examples 'it does not allow choosing invoice terms' do
  it { expect(page).to have_no_field('Invoice terms') }
end

shared_examples 'it allows choosing invoice terms' do
  it { expect(page).to have_field('Invoice terms') }
end

shared_examples 'it applies validation when creating a contract' do
  context 'with invalid data' do
    it { expect { click_on 'Save' }.not_to change(Commercial::Contract, :count) }

    it 'displays errors' do
      click_on 'Save'
      expect(page).to have_text("Name can't be blank")
    end
  end
end

shared_examples 'it successfully creates a contract' do
  it 'creates the model' do
    expect(page).to have_text('Contract has been created')
    expect(Commercial::Contract.last).to have_attributes(expected_attributes)
  end

  it 'does not create any licences' do
    expect(page).to have_text('Contract has been created')
    expect(Commercial::Contract.last.licences).to be_empty
  end
end

describe 'manage contracts', :include_application_helper do
  let(:user) { create(:admin) }

  before do
    sign_in(user)
    visit admin_commercial_path
  end

  context 'when adding a new contract' do
    let!(:product) { create(:commercial_product, :default_product) }
    let!(:funder) { create(:funder) }

    before { click_on 'New contract' }

    context 'when choosing a standard contract' do
      before do
        within('div#standard') do
          click_on 'Create this type of contract'
        end
      end

      it { expect(page).to have_text('Create new standard contract') }

      it_behaves_like 'it shows the common contract fields'
      it_behaves_like 'it allows choosing invoice terms'
      it_behaves_like 'it shows the fields for a non-custom contract'
      it_behaves_like 'it applies validation when creating a contract'

      it 'shows default contract dates' do
        expect(page).to have_field('contract_start_date',
                                   with: Time.zone.today.strftime('%d/%m/%Y'))
        expect(page).to have_field('contract_end_date',
                                   with: (Time.zone.today.next_year - 1.day).strftime('%d/%m/%Y'))
      end

      context 'with valid data', :js do
        before do
          fill_in 'Name', with: 'Standard contract'
          fill_in 'Comments', with: 'Some notes'

          select product.name, from: 'Product'
          choose 'Funder'
          select funder.name, from: 'Contract holder'

          fill_in 'Number of schools', with: 100
          fill_in 'Agreed school price', with: 525

          set_date('#contract_start_date', '01/01/2026')
          set_date('#contract_end_date', '31/12/2026')

          click_on 'Save'
        end

        it_behaves_like 'it successfully creates a contract' do
          let(:expected_attributes) do
            {
              name: 'Standard contract',
              comments: 'Some notes',
              product: product,
              contract_holder: funder,
              licence_period: 'contract',
              invoice_terms: 'full',
              number_of_schools: 100,
              start_date: Date.new(2026, 1, 1),
              end_date: Date.new(2026, 12, 31),
              agreed_school_price: BigDecimal(525),
              created_by: user
            }
          end
        end
      end
    end

    context 'when choosing a pro_rata contract' do
      before do
        within('div#pro-rata') do
          click_on 'Create this type of contract'
        end
      end

      it { expect(page).to have_text('Create new pro-rata contract') }

      it_behaves_like 'it shows the common contract fields'
      it_behaves_like 'it allows choosing invoice terms'
      it_behaves_like 'it shows the fields for a non-custom contract'

      it_behaves_like 'it applies validation when creating a contract'

      context 'with valid data', :js do
        before do
          fill_in 'Name', with: 'Pro-rata contract'
          fill_in 'Comments', with: 'Some notes'

          select product.name, from: 'Product'
          choose 'Funder'
          select funder.name, from: 'Contract holder'

          fill_in 'Number of schools', with: 100
          fill_in 'Agreed school price', with: 525

          set_date('#contract_start_date', '01/01/2026')
          set_date('#contract_end_date', '31/12/2026')

          click_on 'Save'
        end

        it_behaves_like 'it successfully creates a contract' do
          let(:expected_attributes) do
            {
              name: 'Pro-rata contract',
              comments: 'Some notes',
              product: product,
              contract_holder: funder,
              licence_period: 'contract',
              invoice_terms: 'pro_rata',
              number_of_schools: 100,
              start_date: Date.new(2026, 1, 1),
              end_date: Date.new(2026, 12, 31),
              agreed_school_price: BigDecimal(525),
              created_by: user
            }
          end
        end
      end
    end

    context 'when choosing a custom contract' do
      before do
        within('div#custom') do
          click_on 'Create this type of contract'
        end
      end

      it { expect(page).to have_text('Create new custom contract') }

      it_behaves_like 'it shows the common contract fields'
      it { expect(page).to have_no_field('Licence period') }
      it { expect(page).to have_field('Licence years') }

      it_behaves_like 'it does not allow choosing invoice terms'
      it_behaves_like 'it applies validation when creating a contract'

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
          fill_in 'Licence years', with: 2.0

          click_on 'Save'
        end

        it_behaves_like 'it successfully creates a contract' do
          let(:expected_attributes) do
            {
              name: 'Custom contract',
              comments: 'Some notes',
              product: product,
              contract_holder: funder,
              licence_period: 'custom',
              invoice_terms: 'full',
              licence_years: 2.0,
              number_of_schools: 100,
              purchase_order_number: 'PO123',
              start_date: Date.new(2026, 1, 1),
              end_date: Date.new(2026, 12, 31),
              agreed_school_price: BigDecimal(525),
              created_by: user
            }
          end
        end
      end
    end
  end

  context 'when adding a new contract for a School Group' do
    let!(:product) { create(:commercial_product, :default_product) }
    let(:contract_holder) { create(:school_group) }

    before do
      visit admin_school_group_contracts_path(contract_holder)
      click_on 'New contract'
    end

    context 'when choosing a standard contract' do
      before do
        within('div#standard') do
          click_on 'Create this type of contract'
        end
      end

      it 'initialises the form correctly' do
        expect(page).to have_text("Create a new standard contract for #{contract_holder.name}")
      end

      it { expect(page).to have_no_field('Contract holder') }

      it_behaves_like 'it shows the fields for a non-custom contract'
      it_behaves_like 'it allows choosing invoice terms'

      context 'with valid data', :js do
        before do
          fill_in 'Name', with: 'Standard contract'
          fill_in 'Comments', with: 'Some notes'

          select product.name, from: 'Product'
          fill_in 'Number of schools', with: 100
          fill_in 'Agreed school price', with: 525

          set_date('#contract_start_date', '01/01/2026')
          set_date('#contract_end_date', '31/12/2026')

          click_on 'Save'
        end

        it_behaves_like 'it successfully creates a contract' do
          let(:expected_attributes) do
            {
              name: 'Standard contract',
              comments: 'Some notes',
              product: product,
              contract_holder: contract_holder,
              licence_period: 'contract',
              invoice_terms: 'full',
              number_of_schools: 100,
              start_date: Date.new(2026, 1, 1),
              end_date: Date.new(2026, 12, 31),
              agreed_school_price: BigDecimal(525),
              created_by: user
            }
          end
        end
      end
    end

    context 'when choosing a pro_rata contract' do
      before do
        within('div#pro-rata') do
          click_on 'Create this type of contract'
        end
      end

      it {
        expect(page).to have_text("Create a new pro-rata contract for #{contract_holder.name}")
      }

      it_behaves_like 'it shows the fields for a non-custom contract'
      it_behaves_like 'it allows choosing invoice terms'
      it_behaves_like 'it applies validation when creating a contract'

      context 'with valid data', :js do
        before do
          fill_in 'Name', with: 'Pro-rata contract'
          fill_in 'Comments', with: 'Some notes'

          select product.name, from: 'Product'

          fill_in 'Number of schools', with: 100
          fill_in 'Agreed school price', with: 525

          set_date('#contract_start_date', '01/01/2026')
          set_date('#contract_end_date', '31/12/2026')

          click_on 'Save'
        end

        it_behaves_like 'it successfully creates a contract' do
          let(:expected_attributes) do
            {
              name: 'Pro-rata contract',
              comments: 'Some notes',
              product: product,
              contract_holder: contract_holder,
              licence_period: 'contract',
              invoice_terms: 'pro_rata',
              number_of_schools: 100,
              start_date: Date.new(2026, 1, 1),
              end_date: Date.new(2026, 12, 31),
              agreed_school_price: BigDecimal(525),
              created_by: user
            }
          end
        end
      end
    end

    context 'when choosing a custom contract' do
      before do
        within('div#custom') do
          click_on 'Create this type of contract'
        end
      end

      it 'initialises the form correctly' do
        expect(page).to have_text("Create a new custom contract for #{contract_holder.name}")
      end

      it { expect(page).to have_no_field('Contract holder') }

      it_behaves_like 'it does not allow choosing invoice terms'

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
          fill_in 'Licence years', with: 1.0

          click_on 'Save'
        end

        it_behaves_like 'it successfully creates a contract' do
          let(:expected_attributes) do
            {
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
            }
          end
        end
      end
    end
  end

  context 'when adding a new contract for a School' do
    let!(:product) { create(:commercial_product, :default_product) }
    let!(:contract_holder) { create(:school) }

    before do
      visit admin_school_contracts_path(contract_holder)
      click_on 'New contract'

      within('div#standard') do
        click_on 'Create this type of contract'
      end
    end

    context 'with valid data', :js do
      before do
        fill_in 'Name', with: 'Standard contract'
        fill_in 'Comments', with: 'Some notes'

        select product.name, from: 'Product'
        fill_in 'Number of schools', with: 100
        fill_in 'Agreed school price', with: 525

        set_date('#contract_start_date', '01/01/2026')
        set_date('#contract_end_date', '31/12/2026')

        click_on 'Save'
      end

      it 'creates the contract' do
        expect(page).to have_text('Contract has been created')
        expect(Commercial::Contract.last).to have_attributes({
                                                               name: 'Standard contract',
                                                               comments: 'Some notes',
                                                               product: product,
                                                               contract_holder: contract_holder,
                                                               licence_period: 'contract',
                                                               invoice_terms: 'full',
                                                               number_of_schools: 100,
                                                               start_date: Date.new(2026, 1, 1),
                                                               end_date: Date.new(2026, 12, 31),
                                                               agreed_school_price: BigDecimal(525),
                                                               created_by: user
                                                             })
      end

      it 'automatically adds a licence' do
        expect(page).to have_text('Contract has been created and school licence added')
        licence = contract_holder.licences.first
        expect(licence).to have_attributes(contract: Commercial::Contract.last)
      end
    end
  end

  context 'when updating an existing contract' do
    let!(:contract) { create(:commercial_contract, licence_period: :contract, contract_holder: funder) }
    let!(:funder) { create(:funder) }

    before do
      click_on 'All Contracts'
    end

    context 'when the contract is editable' do
      before { click_on 'Edit' }

      it { expect(page).to have_text(contract.name) }

      it {
        expect(page).to have_text(
          'Any changes made to the start and end dates or licence years fields for this contract will be applied to ' \
          'any licences that have not yet been invoiced'
        )
      }

      it { expect(page).to have_no_field('Contract holder') }

      it { expect(page).to have_no_select('Licence period') }
      it { expect(page).to have_no_field('Licence years') }

      it_behaves_like 'it allows choosing invoice terms'

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
          expect(page).to have_text('Contract has been updated')
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

    context 'when the licence period is custom' do
      let!(:contract) { create(:commercial_contract, :custom, contract_holder: funder) }

      before { click_on 'Edit' }

      it { expect(page).to have_text(contract.name) }
      it { expect(page).to have_no_field('Contract holder') }

      it_behaves_like 'it does not allow choosing invoice terms'
    end

    context 'when there are licences' do
      let!(:licence) { create(:commercial_licence, contract:, school: create(:school, data_enabled: false)) }

      before { click_on 'Edit' }

      context 'when making changes to be cascaded', :js do
        before do
          select 'Confirmed', from: 'Status'
          set_date('#contract_start_date', '01/01/2026')
          set_date('#contract_end_date', '31/12/2026')
          check('contract_update_licences')
          click_on 'Save'
        end

        it 'updates the model' do
          expect(page).to have_text('Contract and licences have been updated')
          expect(licence.reload).to have_attributes(
            start_date: Date.new(2026, 1, 1),
            end_date: Date.new(2026, 12, 31),
            status: 'confirmed',
            updated_by: user
          )
        end
      end

      context 'when making changes without cascading them to licences', :js do
        before do
          select 'Confirmed', from: 'Status'
          set_date('#contract_start_date', '01/01/2026')
          set_date('#contract_end_date', '31/12/2026')
          click_on 'Save'
        end

        it 'updates the model' do
          expect(page).to have_text('Contract has been updated')
          original_attributes = licence.attributes
          expect(licence.reload).to have_attributes(original_attributes)
        end
      end
    end

    context 'when the contract has invoiced licences' do
      before do
        create(:commercial_licence, contract:, status: :invoiced)
        click_on 'Edit'
      end

      it { expect(page).to have_text(contract.name) }

      it {
        expect(page).to have_text('One or more licences associated with this contract have already been invoiced')
      }

      it { expect(page).to have_no_field('Contract holder') }
      it { expect(page).to have_no_field('Product') }

      it_behaves_like 'it does not allow choosing invoice terms'

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

    context 'when choosing to renew' do
      before { click_on 'Renew' }

      it { expect(page).to have_text('Choose Renewed Contract Type') }

      it 'indicates the original type' do
        within('div#standard') do
          expect(page).to have_text('Keep the same type as the original contract')
        end
      end

      context 'when renewing as a standard contract', :js do
        before do
          within('div#standard') do
            click_on 'Renew contract'
          end
        end

        it { expect(page).to have_field('Agreed school price', with: contract.agreed_school_price) }
        it { expect(page).to have_field('Comments', with: "Renewed from #{contract.name}") }

        it { expect(page).to have_select('Invoice terms', selected: 'Pro rata') } # this is default for renewed
        it { expect(page).to have_field('contract_licence_period', with: 'contract', type: :hidden, visible: :all) }

        it { expect(page).to have_field('Number of schools', with: contract.number_of_schools) }
        it { expect(page).to have_select('Status', selected: 'Provisional') }

        context 'when submitting with defaults' do # rubocop:disable RSpec/NestedGroups
          subject(:renewed_contract) { contract.contract_holder.contracts.by_start_date.last }

          before do
            fill_in('Name', with: 'Renewed contract')
            click_on 'Save'
          end

          it 'creates the contract' do
            expect(page).to have_text('Contract and provisional licences have been created')
            expect(renewed_contract).to have_attributes(
              name: 'Renewed contract',
              comments: "Renewed from #{contract.name}",
              product: contract.product,
              contract_holder: contract.contract_holder,
              licence_period: contract.licence_period,
              number_of_schools: contract.number_of_schools,
              start_date: contract.end_date + 1.day,
              end_date: contract.end_date.next_year,
              agreed_school_price: contract.agreed_school_price,
              created_by: user
            )
          end

          it 'creates the licences' do
            expect(page).to have_text('Contract and provisional licences have been created')
            expect(renewed_contract.licences.count).to eq(1)
            expect(renewed_contract.licences.first.school).to eq(original_licence.school)
            expect(renewed_contract.licences.first.school_specific_price).to eq(original_licence.school_specific_price)
          end
        end

        context 'when choosing not to add licences' do # rubocop:disable RSpec/NestedGroups
          subject(:renewed_contract) { contract.contract_holder.contracts.by_start_date.last }

          before do
            fill_in('Name', with: 'Renewed contract')
            uncheck('contract_update_licences')
            click_on 'Save'
          end

          it 'does not create the licences' do
            expect(page).to have_text('Contract has been created')
            expect(renewed_contract.licences.count).to eq(0)
          end
        end
      end

      context 'when renewing as a custom contract', :js do
        before do
          within('div#custom') do
            click_on 'Renew contract'
          end
        end

        it { expect(page).to have_text('based on the chosen option the licence period has been changed') }

        it { expect(page).to have_field('Agreed school price', with: contract.agreed_school_price) }
        it { expect(page).to have_field('Comments', with: "Renewed from #{contract.name}") }

        it { expect(page).to have_field('contract_invoice_terms', with: 'full', type: :hidden, visible: :all) }

        it { expect(page).to have_field('contract_licence_period', with: 'custom', type: :hidden, visible: :all) }

        it { expect(page).to have_field('Number of schools', with: contract.number_of_schools) }
        it { expect(page).to have_select('Status', selected: 'Provisional') }
      end
    end
  end

  context 'when viewing a contract' do
    let!(:contract) do
      create(:commercial_contract,
             agreed_school_price: 600.0, xero_account_code: create(:commercial_xero_account_code))
    end

    before do
      click_on 'All Contracts'
      click_on contract.name
    end

    it { expect(page).to have_css('#metadata') }

    it { expect(page).to have_text(contract.name) }
    it { expect(page).to have_text(contract.comments) }
    it { expect(page).to have_link('All contracts', href: admin_commercial_contracts_path) }

    it do
      expect(page).to have_link('Contract holder contracts',
                                href: polymorphic_path([:admin, contract.contract_holder, :contracts]))
    end

    context 'when viewing terms' do
      it {
        expect(page).to have_link(contract.contract_holder.name,
                                  href: polymorphic_path([:admin, contract.contract_holder, :contracts]))
      }

      it { expect(page).to have_text(contract.contract_holder_type) }
      it { expect(page).to have_text(contract.product.name) }
      it { expect(page).to have_text(contract.start_date.to_fs(:es_short)) }
      it { expect(page).to have_text(contract.end_date.to_fs(:es_short)) }
      it { expect(page).to have_text(contract.status.humanize) }
      it { expect(page).to have_text(contract.invoice_terms.humanize) }
      it { expect(page).to have_text(contract.licence_period.humanize) }
      it { expect(page).to have_text(contract.licence_years) }
      it { expect(page).to have_text(contract.number_of_schools) }
      it { expect(page).to have_text(FormatUnit.format(:£, contract.agreed_school_price)) }
      it { expect(page).to have_text(contract.comments) }
      it { expect(page).to have_text(contract.xero_account_code.display_label) }
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
            ['Base price', '£600.00'],
            ['Metering fees', '£0.00'],
            ['Private account fees', '£0.00'],
            ['Total', '£600.00']
          ]
        end
      end
    end

    context 'when viewing contract value' do
      before do
        create(:commercial_licence, status: :confirmed, contract:)
        refresh
      end

      it_behaves_like 'it contains the expected data table', sortable: true, aligned: false, tfoot: true do
        let(:table_id) { '#per-school-fees' }
        let(:expected_header) do
          [
            ['School Group', 'School', 'Base price', 'Metering fee', 'Private account fee', 'Total']
          ]
        end
        let(:expected_rows) do
          [
            ['', contract.schools.first.name, '£600.00', '£0.00', '£0.00', '£600.00']
          ]
        end
        let(:expected_footer_rows) do
          [
            ['', '', '£600.00', '£0.00', '£0.00', '£600.00']
          ]
        end
      end
    end

    context 'when navigating to contract holder page' do
      before { click_on 'Contract holder contracts' }

      it { expect(page).to have_text("#{contract.contract_holder.name} Contracts") }

      it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
        let(:table_id) { '#contracts-table' }
        let(:expected_header) do
          [
            ['Name', 'Product', 'Period', 'Terms', 'Start Date', 'End Date', 'Number of Schools', 'Licensed Schools',
             'Status', 'Actions']
          ]
        end
        let(:expected_rows) do
          [
            [
              contract.name,
              contract.product.name,
              contract.licence_period.humanize,
              contract.invoice_terms.humanize,
              contract.start_date.to_fs(:es_short),
              contract.end_date.to_fs(:es_short),
              contract.number_of_schools.to_s,
              '0',
              contract.status.humanize,
              'Edit Renew Confirm Delete'
            ]
          ]
        end
      end
    end

    context 'when viewing licences' do
      before do
        create(:commercial_licence, status: :confirmed, contract:)
        refresh
      end

      it { expect(page).to have_css('#licences') }
      it { expect(page).to have_no_link('Overlapping licences', href: overlapping_admin_commercial_licences_path) }

      context 'with an overlapping licence' do
        before do
          existing = contract.licences.last
          create(:commercial_licence, school: existing.school, start_date: existing.start_date)
          refresh
        end

        it { expect(page).to have_link('Overlapping licences', href: overlapping_admin_commercial_licences_path) }
        it { expect(page).to have_text('1 of these licences overlap with licences from other contracts') }
      end
    end

    context 'when viewing invoices' do
      let!(:invoice) { create(:commercial_invoice, contract:) }

      before { refresh }

      it { expect(page).to have_text('Invoices') }

      it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
        let(:table_id) { '#invoices-table' }
        let(:expected_header) do
          [
            ['', 'Number', 'User', 'Date', 'Total']
          ]
        end
        let(:expected_rows) do
          [
            [
              '',
              invoice.invoice_number,
              invoice.created_by.display_name,
              invoice.date.to_fs(:es_short),
              format_price(invoice.value.total)
            ]
          ]
        end
      end
    end

    context 'with a School contract' do
      let!(:contract) do
        create(:commercial_contract, :with_school)
      end

      it { expect(page).to have_no_link('Add New Licence') }
      it { expect(page).to have_no_link('Manage All Licences') }
      it { expect(page).to have_no_link('Calculate Price') }
    end
  end

  context 'when confirming a contract' do
    let!(:contract) { create(:commercial_contract, status: :provisional) }

    before do
      click_on 'All Contracts'
      click_on contract.name
    end

    context 'when clicking the button' do
      it 'confirms the contract' do
        click_on 'Confirm'
        expect(page).to have_text('Contract and licences have been confirmed')
        expect(contract.reload.status).to eq('confirmed')
      end

      context 'when there are licences' do
        let!(:licence) { create(:commercial_licence, contract:, school: create(:school, data_enabled: false)) }

        it 'confirms the licences' do
          click_on 'Confirm'
          expect(page).to have_text('Contract and licences have been confirmed')
          expect(licence.reload.status).to eq('confirmed')
        end
      end
    end

    context 'when the contract is already confirmed' do
      let!(:contract) { create(:commercial_contract, status: :confirmed) }

      it { expect(page).to have_no_link('Confirm', href: confirm_admin_commercial_contract_path(contract)) }
    end
  end

  context 'when viewing contract lists' do
    context 'with current' do
      let!(:contract) { create(:commercial_contract) }

      before { click_on 'Current Contracts' }

      it { expect(page).to have_no_field(:date) }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_text(contract.name)
        end
      end
    end

    context 'with expired' do
      let!(:contract) { create(:commercial_contract, :expired) }

      before { click_on 'Expired Contracts' }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_text(contract.name)
        end
      end

      it_behaves_like 'a filtered contract list' do
        let(:filter_date) { (contract.end_date - 1).strftime('%d/%m/%Y') }
        let(:filtered_contract) { contract }
      end
    end

    context 'with expiring' do
      let!(:contract) { create(:commercial_contract, end_date: Time.zone.tomorrow) }

      before { click_on 'Expiring Contracts' }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_text(contract.name)
        end
      end

      it_behaves_like 'a filtered contract list' do
        let(:filter_date) { Time.zone.yesterday.strftime('%d/%m/%Y') }
        let(:filtered_contract) { contract }
      end
    end

    context 'with recent' do
      let!(:contract) { create(:commercial_contract) }

      before { click_on 'Recently Added Contracts' }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_text(contract.name)
        end
      end

      it_behaves_like 'a filtered contract list' do
        let(:filter_date) { Time.zone.tomorrow.strftime('%d/%m/%Y') }
        let(:filtered_contract) { contract }
      end
    end

    context 'with provisional' do
      let!(:contract) { create(:commercial_contract, status: :provisional) }

      before { click_on 'Provisional Contracts' }

      it { expect(page).to have_no_field(:date) }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_text(contract.name)
        end
      end
    end

    context 'with future' do
      let!(:contract) { create(:commercial_contract, :future) }

      before { click_on 'Future Contracts' }

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_text(contract.name)
        end
      end

      it_behaves_like 'a filtered contract list' do
        let(:filter_date) { (contract.start_date + 1).strftime('%d/%m/%Y') }
        let(:filtered_contract) { contract }
      end
    end

    context 'with over licensed' do
      let!(:contract) { create(:commercial_contract, number_of_schools: 2) }

      before do
        create_list(:commercial_licence, 5, contract:)
        click_on 'Over Licensed Contracts'
      end

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_text(contract.name)
        end
      end
    end

    context 'with overlapping' do
      let!(:contract_one) do
        create(:commercial_contract, start_date: Date.new(2024, 1, 1), end_date: Date.new(2024, 12, 31))
      end

      let!(:contract_two) do
        create(:commercial_contract,
               contract_holder: contract_one.contract_holder,
               start_date: Date.new(2024, 6, 1),
               end_date: Date.new(2025, 12, 31))
      end

      before do
        click_on 'Overlapping Contracts'
      end

      it 'shows the contract' do
        within('#contracts-table') do
          expect(page).to have_text(contract_one.name)
          expect(page).to have_text(contract_two.name)
        end
      end
    end
  end

  context 'when viewing contract holders' do
    let!(:contract_holder) { create(:funder) }

    include_context 'with a mixture of contracted schools and onboardings'

    before { click_on 'Contract Holders' }

    it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
      let(:table_id) { '#contract-holders-table' }
      let(:expected_header) do
        [
          ['Name', 'Type', 'Onboarding', 'Visible not data enabled', 'Visible and data enabled', 'Total']
        ]
      end
      let(:expected_rows) do
        [
          [
            contract_holder.name,
            'Funder',
            '1',
            '2',
            '3',
            '6'
          ]
        ]
      end
    end
  end
end
