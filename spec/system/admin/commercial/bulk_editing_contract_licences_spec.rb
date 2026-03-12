require 'rails_helper'

describe 'bulk editing contract licences' do
  let(:user) { create(:admin) }

  let!(:contract) { create(:commercial_contract) }
  let!(:licence) { create(:commercial_licence, contract:) }
  let!(:modified_licence) do
    create(:commercial_licence,
           contract:,
           school_specific_price: 100.0,
           invoice_reference: 'INV-001',
           comments: 'Some comments')
  end

  before do
    sign_in(user)
    visit admin_commercial_contract_path(contract)
    click_on('Manage All Licences')
  end

  it { expect(page).to have_content("#{contract.name} Licence Editor") }

  def field_name(licence, name)
    "commercial_contract[licences_attributes][#{licence.id}][#{name}]"
  end

  def fill_in_field(licence, field, value)
    fill_in(field_name(licence, field), with: value)
  end

  context 'when modifying a single licence', :js do
    before do
      fill_in_field(modified_licence, :school_specific_price, '200.0')
      fill_in_field(modified_licence, :comments, 'Increased price')
      set_date("#commercial_contract_licences_attributes_#{modified_licence.id}_start_date", '01/01/2026')
      set_date("#commercial_contract_licences_attributes_#{modified_licence.id}_end_date", '31/12/2026')
      select('Confirmed', from: field_name(modified_licence, :status))
      click_on('Save changes')
    end

    it 'updates the licence' do
      expect(page).to have_content('Licences updated')
      expect(modified_licence.reload).to have_attributes({
        school_specific_price: 200.0,
        status: 'confirmed',
        comments: 'Increased price',
        start_date: Date.new(2026, 1, 1),
        end_date: Date.new(2026, 12, 31)
      })
    end
  end
end
