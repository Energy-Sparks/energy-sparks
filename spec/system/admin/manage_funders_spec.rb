require 'rails_helper'

describe 'manage funders' do
  let(:user) { create(:admin) }

  before do
    sign_in(user)
    visit admin_path
  end

  context 'when adding a new funder' do
    before do
      click_on('Funders')
      click_on('New Funder')
    end

    context 'with valid data' do
      before do
        fill_in 'Name', with: 'My funder'
        uncheck 'Do we invoice this funder?'
        click_on 'Create'
      end

      it { expect(page).to have_text('Funder was successfully created') }
      it { expect(page).to have_text('My funder') }
    end

    context 'with invalid data' do
      it { expect { click_on 'Create' }.not_to change(Funder, :count) }

      it 'displays errors' do
        click_on 'Create'
        expect(page).to have_text("Name can't be blank")
      end
    end
  end

  context 'when updating an existing funder' do
    let!(:funder) { create(:funder) }

    before do
      click_on('Funders')
      click_on('Edit')
    end

    context 'with valid data' do
      before do
        fill_in 'Name', with: 'New name'
        click_on 'Update'
      end

      it { expect(page).to have_text('Funder was successfully updated') }
      it { expect(page).to have_text(funder.reload.name) }
    end
  end

  context 'when deleting a funder' do
    let!(:funder) { create(:funder) }

    before do
      click_on('Funders')
    end

    it { expect { click_on 'Delete' }.to change(Funder, :count).by(-1) }

    context 'when the funder has a contract' do
      before do
        create(:commercial_contract, contract_holder: funder)
        click_on 'Delete'
      end

      it { expect(page).to have_text('Cannot delete record because dependent contracts exist') }
    end
  end

  context 'when viewing a funder' do
    let!(:funder) { create(:funder, invoiced: true) }

    before do
      click_on('Funders')
    end

    it { expect(page).to have_link('Contracts', href: admin_funder_contracts_path(funder)) }
    it { expect(page).to have_link('Edit', href: edit_admin_funder_path(funder)) }
    it { expect(page).to have_link('Delete', href: admin_funder_path(funder)) }

    context 'with contracts' do
      let!(:contract) { create(:commercial_contract, contract_holder: funder) }

      before do
        click_on(funder.name)
        click_on('Contracts')
      end

      it { expect(page).to have_link(contract.name, href: admin_commercial_contract_path(contract)) }

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

    context 'when showing funded schools' do
      include_context 'with a mixture of contracted schools and onboardings'
      before { click_on(funder.name) }

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#funded-schools' }
        let(:expected_header) do
          [
            %w[Category Schools]
          ]
        end
        let(:expected_rows) do
          [
            ['Onboarding', '1'],
            ['Visible not data enabled', '2'],
            ['Visible and data enabled', '3'],
            ['Total', '6']
          ]
        end
      end
    end
  end
end
