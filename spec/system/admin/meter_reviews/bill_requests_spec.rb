require 'rails_helper'

RSpec.describe 'bill_requests', type: :system do

  let!(:school)                { create(:school) }
  let!(:unreviewed_dcc_meter)  { create(:electricity_meter, school: school, dcc_meter: true, consent_granted: false, meter_review_id: nil) }
  let!(:reviewed_dcc_meter)    { create(:electricity_meter, school: school, dcc_meter: true, consent_granted: true) }

  let!(:admin)                 { create(:admin) }

  before(:each) do
    login_as admin
  end

  context 'with pending meter review' do

    it 'should provide navigation' do
      visit root_path
      click_on 'Admin'
      click_on 'Meter Reviews'
      expect(page).to have_link("Request bill", href: new_admin_school_bill_request_path(school) )
    end
  end

  context 'requesting a bill' do

    context 'with no users' do

      before(:each) do
        visit new_admin_school_bill_request_path(school)
      end

      it 'should say there are no users' do
        expect(page).to have_text("The school has no staff or admin users")
      end

      it 'should link to add a user' do
        expect(page).to have_link("Add user", href: school_users_path(school))
      end
    end

    context 'with users' do
      let!(:school_admin)          { create(:school_admin, school: school)}
      let!(:staff)                 { create(:staff, school: school)}

      before(:each) do
        visit new_admin_school_bill_request_path(school)
      end

      it 'should display user name and role' do
        expect(page).to have_text(staff.name)
        expect(page).to have_text(staff.staff_role.title)
        expect(page).to have_text(school_admin.name)
        expect(page).to have_text(school_admin.staff_role.title)

        expect(page).to have_text(unreviewed_dcc_meter.mpan_mprn)
        expect(page).not_to have_text(reviewed_dcc_meter.mpan_mprn)
      end

      it 'should link to manage users' do
        expect(page).to have_link("Manage users", href: school_users_path(school))
      end

      context 'when invalid form is submitted' do
        it 'should display an error' do
          click_on 'Request bill'
          expect(page.has_text?("You must select at least one user")).to be true
          expect(ActionMailer::Base.deliveries.count).to be 0
        end
      end

      context 'when valid form is submitted' do
        before(:each) do
          expect(page).not_to have_content('Bill last requested from the school on')
          find(:css, "#bill_request_user_ids_#{school_admin.id}").set(true)
          click_on 'Request bill'
        end

        it 'should confirm email has been sent' do
          expect(page.has_text?("Bill has been requested")).to be true
        end

        it 'should send the email' do
          expect(ActionMailer::Base.deliveries.count).to be 1
        end

        it 'should now show a bill requested on time stamp on the bill request page' do
          visit new_admin_school_bill_request_path(school)
          expect(page).to have_content('Bill last requested from the school on')
        end
      end

    end

  end
end
