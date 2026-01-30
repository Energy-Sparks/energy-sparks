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

      it { expect(page).to have_content('Funder was successfully created') }
      it { expect(page).to have_content('My funder') }
    end

    context 'with invalid data' do
      it { expect { click_on 'Create' }.not_to change(Funder, :count) }

      it 'displays errors' do
        click_on 'Create'
        expect(page).to have_content("Name can't be blank")
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

      it { expect(page).to have_content('Funder was successfully updated') }
      it { expect(page).to have_content(funder.reload.name) }
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

      it { expect(page).to have_content('Cannot delete a funder with contracts') }
    end
  end

  context 'when viewing a funder' do
    let!(:funder) { create(:funder) }

    before do
      click_on('Funders')
    end

    context 'with contracts' do
      let!(:contract) { create(:commercial_contract, contract_holder: funder) }

      before do
        click_on(funder.name)
      end

      it { expect(page).to have_link(contract.name, href: admin_commercial_contract_path(contract)) }

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#all-contracts-table' }
        let(:expected_header) do
          [
            ['Name', 'Contract Holder', 'Product', 'Start Date', 'End Date', 'Number of Schools', 'Licensed Schools', 'Status', 'Actions']
          ]
        end
        let(:expected_rows) do
          [
            [
              contract.name,
              contract.contract_holder.name,
              contract.product.name,
              contract.start_date.iso8601,
              contract.end_date.iso8601,
              contract.number_of_schools.to_s,
              '0',
              contract.status.humanize,
              'Edit Delete'
            ]
          ]
        end
      end
    end
  end
end
