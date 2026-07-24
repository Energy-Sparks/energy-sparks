# frozen_string_literal: true

require 'rails_helper'

describe 'manage xero account codes' do
  let(:user) { create(:admin) }

  before do
    sign_in(user)
    visit admin_commercial_path
  end

  context 'when adding a new code' do
    before do
      click_on 'Xero Account Codes'
      click_on 'New account code'
      fill_in 'Code', with: 42
      fill_in 'Label', with: 'The label'
    end

    it 'creates the code' do
      expect { click_on 'Save' }.to change(Commercial::XeroAccountCode, :count).by(1)
      expect(page).to have_text('Code was successfully created')
      expect(Commercial::XeroAccountCode.last).to have_attributes(code: 42, label: 'The label')
    end
  end

  context 'when deleting a code' do
    before do
      create(:commercial_xero_account_code)
      click_on 'Xero Account Codes'
    end

    it 'deletes the code' do
      expect { click_on 'Delete' }.to change(Commercial::XeroAccountCode, :count).by(-1)
    end
  end

  context 'when editing a code' do
    before do
      create(:commercial_xero_account_code)
      click_on 'Xero Account Codes'
      click_on 'Edit'
      fill_in 'Label', with: 'Updated label'
      click_on 'Save'
    end

    it 'updates the code' do
      expect(page).to have_text('Code was successfully updated')
      expect(Commercial::XeroAccountCode.last).to have_attributes(label: 'Updated label')
    end
  end
end
