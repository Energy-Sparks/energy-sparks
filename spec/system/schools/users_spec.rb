# frozen_string_literal: true

require 'rails_helper'

describe 'School admin user management' do
  let(:school) { create(:school) }
  let(:school_admin) { create(:school_admin, school:) }

  describe 'as school admin' do
    before do
      sign_in(school_admin)
      visit school_users_path(school)
    end

    it 'is present on the school menu' do
      visit school_path(school)
      click_on 'Manage users'
      expect(page).to have_selector(:link_or_button, 'New staff account')
    end

    describe 'for pupils' do
      it 'can create pupils' do
        click_on 'Manage users'
        click_on 'New pupil account'

        fill_in 'Name', with: 'The Pupils'
        fill_in 'Pupil password', with: 'the elektrons'
        click_on 'Create account'

        pupil = school.users.pupil.first
        expect(pupil.email).not_to be_nil
        expect(pupil.pupil_password).to eq('the elektrons')

        expect(ActionMailer::Base.deliveries.last).to be_nil
      end

      it 'can edit and delete pupils' do
        pupil = create(:pupil, school:)
        click_on 'Manage users'
        within '.pupils' do
          click_on 'Edit'
        end

        fill_in 'Name', with: 'Dave'
        click_on 'Update account'

        pupil.reload
        expect(pupil.name).to eq('Dave')

        within '.pupils' do
          click_on 'Delete'
        end

        expect(school.users.pupil.count).to eq(0)
      end
    end

    describe 'for staff' do
      let!(:teacher_role) { create(:staff_role, :teacher, title: 'Teacher or teaching assistant') }

      context 'when creating staff' do
        before do
          click_on 'Manage users'
          click_on 'New staff account'
          fill_in 'Name', with: 'Mrs Jones'
          fill_in 'Email', with: 'mrsjones@test.com'
          select 'Teacher or teaching assistant', from: 'Role'
        end

        it 'can create staff' do
          expect { click_on 'Create account' }.to change(User, :count).by(1).and change(Contact, :count).by(0)

          staff = school.users.staff.first
          expect(staff.email).to eq('mrsjones@test.com')
          expect(staff.staff_role).to eq(teacher_role)
          expect(staff.confirmed?).to be false

          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq('Please confirm your account on Energy Sparks')
          expect(email.encoded).to match(school.name)
        end
      end

      it 'can edit and delete staff' do
        staff = create(:staff, school:)
        click_on 'Manage users'
        within '.staff' do
          click_on 'Edit'
        end

        expect(page).to have_content('Edit staff account')

        fill_in 'Name', with: 'Ms Jones'
        click_on 'Update account'

        staff.reload
        expect(staff.name).to eq('Ms Jones')

        within '.staff' do
          click_on 'Delete'
        end
        expect(school.users.staff.count).to eq(0)
      end

      it 'can edit alert contact' do
        staff = create(:staff, school:)
        create(:contact, name: staff.name, user: staff, email_address: staff.email, school:)
        click_on 'Manage users'
        within '.staff' do
          click_on 'Edit'
        end

        uncheck 'Subscribe to school alerts'
        expect { click_on 'Update account' }.to change(Contact, :count).by(-1)

        within '.staff' do
          click_on 'Edit'
        end
        expect(page).to have_no_checked_field('contact_auto_create_alert_contact')
        check 'Subscribe to school alerts'
        expect { click_on 'Update account' }.to change(Contact, :count).by(1)
      end

      it 'cannot edit alert contact if user is not yet confirmed' do
        create(:staff, school:, confirmed_at: nil)
        click_on 'Manage users'
        within '.staff' do
          click_on 'Edit'
        end

        expect(page).to have_no_content 'Subscribe to school alerts'
      end

      it 'can update contact email address if contact has user association' do
        staff = create(:staff, school:)
        contact = create(:contact, name: staff.name, user: staff, email_address: staff.email, school:)
        click_on 'Manage users'
        within '.staff' do
          click_on 'Edit'
        end

        fill_in 'Email', with: 'blah@test.com'

        expect { click_on 'Update account' }.not_to(change(Contact, :count))

        contact.reload
        expect(contact.email_address).to eq('blah@test.com')
      end

      it 'can update contact when contact exists for that email without user association' do
        staff = create(:staff, school:)
        contact = create(:contact, name: staff.name, user: nil, email_address: staff.email, school:)
        click_on 'Manage users'
        within '.staff' do
          click_on 'Edit'
        end

        expect { click_on 'Update account' }.not_to(change(Contact, :count))

        contact.reload
        expect(contact.user).to eq(staff)
      end

      it 'can remove contact when contact exists for that email without user association' do
        staff = create(:staff, school:)
        contact = create(:contact, name: staff.name, user: nil, email_address: staff.email, school:)
        click_on 'Manage users'
        within '.staff' do
          click_on 'Edit'
        end

        uncheck 'Subscribe to school alerts'
        expect { click_on 'Update account' }.to change(Contact, :count).by(-1)
        expect { contact.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'can promote staff user to school admin' do
        staff = create(:staff, school:)
        create(:contact, name: staff.name, user: nil, email_address: staff.email, school:)
        click_on 'Manage users'
        within '.staff' do
          expect(page).to have_content(staff.name)
          click_on 'Make school admin'
        end

        within '.school_admin' do
          expect(page).to have_content(staff.name)
        end

        staff.reload
        expect(staff.role).to eq('school_admin')
      end

      it 'no lock if not an admin' do
        click_on 'Manage users'
        expect(page).to have_no_selector(:link_or_button, 'Lock')
      end

      context 'when displaying users' do
        it 'shows preferred language' do
          create(:staff, school:, preferred_locale: :cy)
          click_on 'Manage users'
          within '.staff' do
            expect(page).to have_content('Welsh')
          end
        end
      end
    end

    describe 'managing school admins' do
      context 'when adding a user' do
        before do
          click_on 'Manage users'
          click_on 'New school admin account'
          fill_in 'Name', with: 'Mrs Jones'
          fill_in 'Email', with: 'mrsjones@test.com'
          select 'Business manager', from: 'Role'
        end

        it 'can create a school admin' do
          click_on 'Create account'
          school_admin = school.users.school_admin.last
          expect(school_admin.email).to eq('mrsjones@test.com')
          expect(school_admin.confirmed?).to be false
        end

        it 'emails new user to confirm account' do
          click_on 'Create account'
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq('Please confirm your account on Energy Sparks')
          expect(email.encoded).to match(school.name)
        end
      end

      context 'when managing a user' do
        let(:new_admin) { create(:school_admin, name: 'New admin', school:) }
        let!(:contact) { create(:contact_with_name_email, user: new_admin, school:) }

        before do
          click_on 'Manage users'
        end

        it 'can edit fields' do
          within '.school_admin' do
            # this avoids problems with ambiguous matches in find/click_on
            # find the row for the new admin, using name set above
            tr = find(:xpath, '//td', text: new_admin.name).ancestor('tr')
            # click on the edit for that row
            within tr do
              click_on 'Edit'
            end
          end

          expect(page).to have_content('Edit school admin account')

          fill_in 'Name', with: 'Ms Jones'
          click_on 'Update account'

          expect(page).to have_content('Ms Jones')
          new_admin.reload
          expect(new_admin.name).to eq('Ms Jones')
        end

        it 'can edit alert contact' do
          within '.school_admin' do
            # this avoids problems with ambiguous matches in find/click_on
            # find the row for the new admin, using name set above
            tr = find(:xpath, '//td', text: new_admin.name).ancestor('tr')
            # click on the edit for that row
            within tr do
              click_on 'Edit'
            end
          end
          uncheck 'Subscribe to school alerts'
          expect { click_on 'Update account' }.to change(Contact, :count).by(-1)

          within '.school_admin' do
            # this avoids problems with ambiguous matches in find/click_on
            # find the row for the new admin, using name set above
            tr = find(:xpath, '//td', text: new_admin.name).ancestor('tr')
            # click on the edit for that row
            within tr do
              click_on 'Edit'
            end
          end
          expect(page).to have_no_checked_field('contact_auto_create_alert_contact')
          check 'Subscribe to school alerts'
          expect { click_on 'Update account' }.to change(Contact, :count).by(1)
        end

        context 'when deleting' do
          before do
            within '.school_admin' do
              # there's only one delete button because users cant delete themselves
              click_on 'Delete'
            end
          end

          it 'removes the user' do
            expect(school.users.school_admin.count).to eq(1)
          end

          it 'removes alert contact' do
            expect(school.contacts.count).to eq(0)
          end
        end
      end

      context 'when adding an existing user' do
        let!(:other_school_admin) { create(:school_admin, name: 'Other admin') }
        let!(:contact) { create(:contact_with_name_email, user: other_school_admin, school: other_school_admin.school) }

        before do
          click_on 'Manage users'
        end

        it 'has option to add another school admin' do
          expect(page).to have_content('Add an existing Energy Sparks user as a school admin')
          click_on 'Add an existing Energy Sparks user as a school admin'
          expect(page).to have_content('Add an existing user as a school admin')
        end

        it 'warns if user not found' do
          click_on 'Add an existing Energy Sparks user as a school admin'
          click_on 'Add user'
          expect(page).to have_content('We were unable to find a user with this email address')
        end

        it 'adds the user' do
          click_on 'Add an existing Energy Sparks user as a school admin'
          fill_in 'Email', with: other_school_admin.email
          click_on 'Add user'
          expect(page).to have_content(other_school_admin.name)
          other_school_admin.reload
          expect(other_school_admin.cluster_schools_for_switching).to eq([school])
        end

        it 'adds the user as an alert contact, by default' do
          click_on 'Add an existing Energy Sparks user as a school admin'
          fill_in 'Email', with: other_school_admin.email
          expect { click_on 'Add user' }.to change(Contact, :count).by(1)
        end

        it 'doesnt add alert contact if requested' do
          click_on 'Add an existing Energy Sparks user as a school admin'
          fill_in 'Email', with: other_school_admin.email
          uncheck 'Subscribe to school alerts'
          expect { click_on 'Add user' }.not_to(change(Contact, :count))
        end
      end

      context 'when managing an existing user' do
        let!(:other_school_admin) { create(:school_admin, name: 'Other admin', cluster_schools: [school]) }
        let!(:contact) { create(:contact_with_name_email, user: other_school_admin, school: other_school_admin.school) }

        before do
          click_on 'Manage users'
        end

        it 'can edit fields' do
          expect(page).to have_content('Other admin')
          within '.school_admin' do
            # this avoids problems with ambiguous matches in find/click_on
            # find the row for the new admin, using name set above
            tr = find(:xpath, '//td', text: other_school_admin.name).ancestor('tr')
            # click on the edit for that row
            within tr do
              click_on 'Edit'
            end
          end

          fill_in 'Name', with: 'Ms Jones'
          click_on 'Update account'

          expect(page).to have_content('Ms Jones')
          other_school_admin.reload
          expect(other_school_admin.name).to eq('Ms Jones')
        end

        context 'when deleting' do
          before do
            within '.school_admin' do
              # there's only one delete button because users cant delete themselves
              click_on 'Delete'
            end
          end

          it 'removes the user' do
            other_school_admin.reload
            expect(other_school_admin.cluster_schools_for_switching).to eq([])
          end

          it 'removes alert contact' do
            expect(school.contacts.count).to eq(0)
          end
        end
      end

      context 'when displaying users' do
        it 'shows preferred language' do
          create(:school_admin, school:, preferred_locale: :cy)
          click_on 'Manage users'
          within '.school_admin' do
            expect(page).to have_content('Welsh')
          end
        end
      end
    end
  end

  describe 'as an admin' do
    let!(:staff) { create(:staff, school:, confirmed_at: nil) }
    let!(:admin) { create(:admin) }
    let!(:pupil) { create(:pupil, school:) }

    let(:deliveries)  { ActionMailer::Base.deliveries.count }
    let(:email)       { ActionMailer::Base.deliveries.last }

    before do
      sign_in(admin)
      visit school_users_path(school)
      click_on('Manage users')
    end

    it 'send confirmation email' do
      expect(staff.confirmed?).to be false
      click_on('Resend confirmation')
      # this is 2 as Devise will send one because the user we just created isnt
      # confirmed. So we're looking for 2 deliveries
      expect(deliveries).to eq 2
      # check the email we just sent
      expect(email.subject).to eq 'Please confirm your account on Energy Sparks'
      expect(page).to have_content('Confirmation email sent')
      expect(page).to have_content('School admin accounts')
    end

    it 'can lock users' do
      within('.staff') { click_on 'Lock' }
      expect(staff.reload.locked_at).not_to be_nil
    end

    it 'can unlock users' do
      staff.lock_access!(send_instructions: false)
      refresh
      within('.staff') { click_on 'Unlock' }
      expect(staff.reload.locked_at).to be_nil
    end

    it 'can lock pupils' do
      within('.pupils') { click_on 'Lock' }
      expect(pupil.reload.locked_at).not_to be_nil
    end

    it 'can unlock pupils' do
      pupil.lock_access!(send_instructions: false)
      refresh
      within('.pupils') { click_on 'Unlock' }
      expect(pupil.reload.locked_at).to be_nil
    end
  end
end
