require 'rails_helper'

describe 'Partners', type: :system do

  let!(:admin)  { create(:admin) }

  describe 'Managing' do

    before do
      sign_in(admin)
    end

    it 'allows the user to create a partner' do
      visit root_path
      click_on 'Admin'
      click_on 'Partners', match: :first

      click_on 'New partner'
      fill_in 'Position', with: '1'
      fill_in 'Url', with: 'https://example.com'
      fill_in 'Name', with: "Sheffield"

      attach_file("Image", Rails.root + "spec/fixtures/images/sheffield.png")
      expect { click_on 'Create Partner' }.to change { Partner.count }.by(1)

      expect(page).to have_xpath("//img[contains(@src,'sheffield.png')]")
      expect(page).to have_link(href: 'https://example.com')
      expect(page).to have_content("Sheffield")
    end

    context "an existing partner" do
      let!(:partner)       { create(:partner) }

      before(:each) do
        visit admin_partners_path
      end

      it 'allows user to view the partner' do
        click_on 'Show'
        expect(page).to have_content(partner.name)
      end

      it 'allows the user to edit a partner' do
        click_on 'Edit'
        fill_in 'Position', with: ''

        click_on 'Update Partner'
        expect(page).to have_content('blank')
        fill_in 'Position', with: '1'
        attach_file("Image", Rails.root + "spec/fixtures/images/banes.png")
        fill_in 'Name', with: "Bath"
        click_on 'Update Partner'

        expect(page).to have_xpath("//img[contains(@src,'banes.png')]")
        expect(page).to have_content("Bath")
      end

      it 'allows the user to delete a partner' do
        expect { click_on 'Delete' }.to change { Partner.count }.by(-1)
        expect(page).to have_content('Partner was successfully destroyed.')
      end
    end

    context "a partner associated with a school group" do
      let(:school_group)          { create(:school_group, name: "Local School Group") }
      let(:partner)               { create(:partner) }
      let(:school)                { create(:school, name: "Partnered School") }

      before(:each) do
        partner.school_groups << school_group
        partner.schools << school
        visit admin_partner_path(partner)
      end

      it 'lists the groups on partner page' do
        expect(page).to have_content("Local School Group")
      end

      it "lists the schools on the partner page" do
        expect(page).to have_content("Partnered School")
      end
    end

  end
end
