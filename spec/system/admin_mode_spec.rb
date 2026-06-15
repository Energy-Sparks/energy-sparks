require 'rails_helper'

describe 'Admin mode' do
  let(:staff)     { create(:staff) }
  let(:admin)     { create(:admin) }

  context 'when logging in' do
    it 'allows form to be viewed' do
      ClimateControl.modify ADMIN_MODE: 'true' do
        visit new_user_session_path
        expect(page).to have_content('Sign in to Energy Sparks')
      end
    end

    it 'serves maintenance page for non-admins' do
      ClimateControl.modify ADMIN_MODE: 'true' do
        visit new_user_session_path
        fill_in 'Email', with: staff.email
        fill_in 'Password', with: staff.password
        within '#staff' do
          click_on 'Sign in'
        end
        expect(page).to have_content('Energy Sparks is currently down for maintenance')
      end
    end

    it 'serves expected page for admins' do
      ClimateControl.modify ADMIN_MODE: 'true' do
        visit new_user_session_path
        fill_in 'Email', with: admin.email
        fill_in 'Password', with: admin.password
        within '#staff' do
          click_on 'Sign in'
        end
        expect(page).to have_content('Energy Sparks schools across the UK')
      end
    end
  end

  context 'when logged in' do
    context 'as admin' do
      it 'serves expected page for admins' do
        ClimateControl.modify ADMIN_MODE: 'true' do
          sign_in(admin)
          visit root_path
          expect(page).to have_content('Energy Sparks schools across the UK')
        end
      end
    end

    context 'as staff' do
      it 'serves maintenance page for non-admins' do
        ClimateControl.modify ADMIN_MODE: 'true' do
          sign_in(staff)
          visit root_path
          expect(page).to have_content('Energy Sparks is currently down for maintenance')
        end
      end
    end
  end

  context 'when not logged in' do
    it 'serves maintenance page for non-admins' do
      ClimateControl.modify ADMIN_MODE: 'true' do
        visit root_path
        expect(page).to have_content('Energy Sparks is currently down for maintenance')
      end
    end
  end
end
