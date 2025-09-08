require 'rails_helper'

RSpec.describe 'bill_requests', type: :system do
  let!(:school)                { create(:school) }
  let!(:unreviewed_dcc_meter)  { create(:electricity_meter, school: school, dcc_meter: :smets2, consent_granted: false, meter_review_id: nil) }
  let!(:reviewed_dcc_meter)    { create(:electricity_meter, school: school, dcc_meter: :smets2, consent_granted: true) }

  let!(:admin)                 { create(:admin) }

  before do
    login_as admin
  end

  context 'with pending meter review' do
    it 'provides navigation' do
      visit root_path
      click_on 'Admin'
      click_on 'Meter Reviews'
      expect(page).to have_link('Request bill', href: new_admin_school_bill_request_path(school))
    end
  end

  context 'requesting a bill' do
    context 'with no users' do
      before do
        visit new_admin_school_bill_request_path(school)
      end

      it 'says there are no users' do
        expect(page).to have_text('The school has no staff or admin users')
      end

      it 'links to add a user' do
        expect(page).to have_link('Add user', href: school_users_path(school))
      end
    end

    context 'with users' do
      let!(:school_admin)          { create(:school_admin, school: school)}
      let!(:staff)                 { create(:staff, school: school)}

      before do
        visit new_admin_school_bill_request_path(school)
      end

      it 'displays user name and role' do
        expect(page).to have_text(staff.name)
        expect(page).to have_text(staff.staff_role.title)
        expect(page).to have_text(school_admin.name)
        expect(page).to have_text(school_admin.staff_role.title)

        expect(page).to have_text(unreviewed_dcc_meter.mpan_mprn)
        expect(page).not_to have_text(reviewed_dcc_meter.mpan_mprn)
      end

      it 'links to manage users' do
        expect(page).to have_link('Manage users', href: school_users_path(school))
      end

      context 'when invalid form is submitted' do
        it 'displays an error' do
          click_on 'Request bill'
          expect(page.has_text?('You must select at least one user')).to be true
          expect(ActionMailer::Base.deliveries.count).to be 0
        end
      end

      context 'when valid form is submitted' do
        before do
          expect(page).not_to have_content('Bill last requested from the school on')
          find(:css, "#bill_request_user_ids_#{school_admin.id}").set(true)
          click_on 'Request bill'
        end

        it 'confirms email has been sent' do
          expect(page.has_text?('Bill has been requested')).to be true
        end

        it 'sends the email' do
          expect(ActionMailer::Base.deliveries.count).to be 1
        end

        it 'nows show a bill requested on time stamp on the bill request page' do
          visit new_admin_school_bill_request_path(school)
          expect(page).to have_content('Bill last requested from the school on')
        end
      end
    end
  end

  context 'when clear the bill request' do
    it 'provides navigation' do
      school.update!(bill_requested: true)
      visit admin_meter_reviews_path
      click_on 'Clear bill request'
      expect(school.reload.bill_requested).to be false
    end
  end
end
