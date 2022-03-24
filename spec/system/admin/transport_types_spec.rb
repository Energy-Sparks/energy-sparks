require 'rails_helper'

describe "admin transport type", type: :system do

  let!(:admin)  { create(:admin) }

  describe 'when not logged in' do
    context "and viewing the index" do
      before(:each) do
        visit admin_transport_types_path
      end

      it 'does not authorise viewing' do
        expect(page).to have_content('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'when logged in' do

    before(:each) do
      sign_in(admin)
    end

    describe "Viewing the index" do

      let!(:transport_type) { create(:transport_type, name: 'sonic jet') }

      before(:each) do
        visit admin_transport_types_path
        @table = find(:table)
      end

      it "lists created transport type" do
        expect(@table).to have_selector(:table_row, ['sonic jet'])
      end
    end
  end
end
