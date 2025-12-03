# frozen_string_literal: true

require 'rails_helper'

describe 'School user management' do
  include ActiveJob::TestHelper

  let(:school) { create(:school) }
  let(:school_admin) { create(:school_admin, school:) }

  shared_examples 'can edit and delete an existing user' do
    let(:role) { :pupil }

    before { visit school_users_path(school) }

    context 'when editing' do
      before do
        within "##{role}" do
          click_on 'Edit'
        end

        fill_in 'Name', with: 'New name'
        click_on 'Update account'
      end

      it { expect(user.reload.name).to eq('New name') }
    end

    context 'when deleting' do
      before do
        within "##{role}" do
          click_on 'Delete'
        end
      end

      it { expect(school.users.where(role:).count).to eq(0) }
    end
  end

  shared_examples 'can manage alerts' do
    let(:role) { :staff }

    context 'when user not confirmed' do
      let!(:user) { create(role, school:, confirmed_at: nil) }

      before do
        visit school_users_path(school)
        within "##{role}" do
          click_on 'Edit'
        end
      end

      it { expect(page).to have_no_content 'Subscribe to school alerts' }
    end

    context 'when not subscribed to alerts' do
      before do
        visit school_users_path(school)
        within "##{role}" do
          click_on 'Edit'
        end
        check 'Subscribe to school alerts'
      end

      it { expect { click_on 'Update account' }.to change(Contact, :count).by(1) }
    end

    context 'when subscribed to alerts' do
      before do
        create(:contact, name: user.name, user:, email_address: user.email, school:)
        visit school_users_path(school)
        within "##{role}" do
          click_on 'Edit'
        end

        uncheck 'Subscribe to school alerts'
      end

      it { expect { click_on 'Update account' }.to change(Contact, :count).by(-1) }
    end

    context 'when editing user email' do
      let!(:contact) { create(:contact, name: user.name, user:, email_address: user.email, school:) }

      before do
        visit school_users_path(school)
        within "##{role}" do
          click_on 'Edit'
        end

        fill_in 'Email', with: 'blah@test.com'
      end

      it 'updates the contact email' do
        expect { click_on 'Update account' }.not_to(change(Contact, :count))
        expect(contact.reload.email_address).to eq('blah@test.com')
      end
    end
  end

  describe 'with a logged in school admin' do
    before do
      sign_in(school_admin)
    end

    describe 'when managing pupils' do
      before { visit school_users_path(school) }

      context 'when creating an account' do
        before do
          click_on I18n.t('schools.users.index.new_pupil_account')
          fill_in 'Name', with: 'The Pupils'
          fill_in 'Pupil password', with: 'the elektrons'
          click_on 'Create account'
        end

        subject(:pupil) { school.users.pupil.first }

        it 'creates the account' do
          expect(pupil.email).not_to be_nil
          expect(pupil.pupil_password).to eq('the elektrons')
        end

        it 'does not send an email' do
          expect(ActionMailer::Base.deliveries.last).to be_nil
        end
      end

      context 'with an existing account' do
        let!(:user) { create(:pupil, school:) }

        it_behaves_like 'can edit and delete an existing user' do
          let(:role) { :pupil }
        end
      end
    end

    describe 'when managing staff' do
      let!(:teacher_role) { create(:staff_role, :teacher, title: 'Teacher or teaching assistant') }

      before { visit school_users_path(school) }

      context 'when creating an account' do
        let(:name) { 'Mrs Jones' }

        before do
          click_on 'New staff account'
          fill_in 'Name', with: name
          fill_in 'Email', with: 'mrsjones@test.com'
          select teacher_role.title, from: 'Role'
        end

        it 'creates the user' do
          expect { click_on 'Create account' }.to change(User, :count).by(1).and change(Contact, :count).by(0)
          staff = school.users.staff.first
          expect(staff.email).to eq('mrsjones@test.com')
          expect(staff.staff_role).to eq(teacher_role)
          expect(staff.confirmed?).to be false
          expect(staff.created_by).to eq(school_admin)
        end

        it 'sends an email' do
          click_on 'Create account'
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq('Please confirm your account on Energy Sparks')
        end

        context 'with an invalid form' do
          let(:name) { '' }

          before { click_on 'Create account' }

          it { expect(page).to have_text("Name *\ncan't be blank") }
        end
      end

      context 'with an existing account' do
        let!(:user) { create(:staff, school:, preferred_locale: :cy) }

        it_behaves_like 'can edit and delete an existing user' do
          let(:role) { :staff }
        end

        it 'does not have option to lock accounts' do
          visit school_users_path(school)
          expect(page).to have_no_selector(:link_or_button, 'Lock')
        end

        it 'shows preferred language' do
          visit school_users_path(school)
          within '#staff' do
            expect(page).to have_content('Welsh')
          end
        end

        it 'does not have link to profile' do
          visit school_users_path(school)
          within('#staff') do
            expect(page).not_to have_link(user.name, href: user_path(user))
          end
        end

        context 'when promoting to school admin' do
          before do
            visit school_users_path(school)
            within '#staff' do
              click_on 'Make school admin'
            end
          end

          it { expect(user.reload.role).to eq('school_admin') }
        end

        context 'when managing alerts' do
          it_behaves_like 'can manage alerts' do
            let(:role) { :staff }
          end

          context 'when there is an orphaned contact' do
            let!(:contact) { create(:contact, name: user.name, user: nil, email_address: user.email, school:) }

            context 'when user is edited' do
              before do
                visit school_users_path(school)
                within '#staff' do
                  click_on 'Edit'
                end

                click_on 'Update account'
              end

              it 'links the contact when user is edited' do
                expect(contact.reload.user).to eq(user)
              end
            end

            context 'when user is unsubscribed' do
              before do
                visit school_users_path(school)
                within '#staff' do
                  click_on 'Edit'
                end

                uncheck 'Subscribe to school alerts'
              end

              it 'removes the contact' do
                expect { click_on 'Update account' }.to change(Contact, :count).by(-1)
                expect { contact.reload }.to raise_error(ActiveRecord::RecordNotFound)
              end
            end
          end
        end
      end
    end

    describe 'when managing students' do
      before { visit school_users_path(school) }

      context 'when creating an account' do
        let(:name) { 'Mrs Jones' }

        before do
          click_on 'New student account'
          fill_in 'Name', with: name
          fill_in 'Email', with: 'user@test.com'
        end

        it 'creates the user' do
          expect { click_on 'Create account' }.to change(User, :count).by(1).and change(Contact, :count).by(0)
          user = school.users.student.first
          expect(user.email).to eq('user@test.com')
          expect(user.staff_role).to be_nil
          expect(user.confirmed?).to be false
          expect(user.created_by).to eq(school_admin)
        end

        it 'sends an email' do
          click_on 'Create account'
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq('Please confirm your account on Energy Sparks')
        end

        context 'with an invalid form' do
          let(:name) { '' }

          before { click_on 'Create account' }

          it { expect(page).to have_text("Name *\ncan't be blank") }
        end
      end

      context 'with an existing account' do
        let!(:user) { create(:student, school:, preferred_locale: :cy) }

        it_behaves_like 'can edit and delete an existing user' do
          let(:role) { :student }
        end

        it 'shows preferred language' do
          visit school_users_path(school)
          within '#student' do
            expect(page).to have_content('Welsh')
          end
        end

        it 'does not have link to profile' do
          visit school_users_path(school)
          within('#student') do
            expect(page).not_to have_link(user.name, href: user_path(user))
          end
        end

        it 'does not have link to promote' do
          visit school_users_path(school)
          within('#student') do
            expect(page).not_to have_link('Make school admin')
          end
        end

        context 'when managing alerts' do
          it_behaves_like 'can manage alerts' do
            let(:role) { :student }
          end
        end
      end
    end

    describe 'managing school admins' do
      it 'only shows the email input' do
        visit school_users_path(school)
        click_on 'New school admin account'
        expect(all('form label').map(&:text)).to eq(['Email *'])
      end

      it 'validates the email' do
        visit school_users_path(school)
        click_on 'New school admin account'
        fill_in 'Email', with: 'invalid email'
        click_on 'Continue'
        expect(first('.form-group').text).to eq("Email *\nis invalid")
      end

      context 'when adding a user' do
        before do
          visit school_users_path(school)
          click_on 'New school admin account'
          fill_in 'Email', with: 'mrsjones@test.com'
          click_on 'Continue'
          fill_in 'Name', with: 'Mrs Jones'
          select 'Business manager', from: 'Role'
          click_on 'Create account'
        end

        it 'can create a school admin' do
          school_admin = school.users.school_admin.last
          expect(school_admin.email).to eq('mrsjones@test.com')
          expect(school_admin.confirmed?).to be false
        end

        it 'emails new user to confirm account' do
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eq('Please confirm your account on Energy Sparks')
          expect(email.encoded).to match(school.name)
        end
      end

      context 'when managing a user' do
        let(:new_admin) { create(:school_admin, name: 'New admin', school:) }
        let!(:contact) { create(:contact_with_name_email, user: new_admin, school:) }

        before do
          visit school_users_path(school)
        end

        it 'can edit fields' do
          within '#school_admin' do
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
          within '#school_admin' do
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

          within '#school_admin' do
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
            within '#school_admin' do
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

      context 'when adding an existing user as an admin' do
        let!(:other_school_admin) { create(:school_admin, :subscribed_to_alerts, name: 'Other admin') }

        before do
          visit school_users_path(school)
          click_on 'New school admin account'
        end

        it 'adds the user' do
          Flipper.enable(:onboarding_mailer_2025)
          fill_in 'Email', with: other_school_admin.email
          click_on 'Continue'
          expect(page).to have_content('Added user as a school admin')
          expect(page).to have_content(other_school_admin.name)
          other_school_admin.reload
          expect(other_school_admin.cluster_schools_for_switching).to eq([school])
          perform_enqueued_jobs
          expect(ActionMailer::Base.deliveries.last.subject).to \
            eq("Welcome to the #{school.name} Energy Sparks account")
        end

        context 'when the other user is staff' do
          let!(:other_school_admin) { create(:staff, name: 'Other admin') }

          it 'adds the user' do
            fill_in 'Email', with: other_school_admin.email
            click_on 'Continue'
            other_school_admin.reload
            expect(other_school_admin.cluster_schools_for_switching).to eq([school])
            expect(other_school_admin.role).to eq 'school_admin'
          end
        end

        context 'with a group admin' do
          let!(:other_school_admin) { create(:group_admin, name: 'Group admin') }

          it 'notifies about a group admin' do
            fill_in 'Email', with: other_school_admin.email
            click_on 'Continue'
            expect(page).to have_content("As a group admin for #{other_school_admin.school_group.name}, this user is" \
                                         ' already able to administer this school')
          end
        end
      end

      context 'when managing an existing user' do
        let!(:other_school_admin) { create(:school_admin, name: 'Other admin', cluster_schools: [school]) }
        let!(:contact) { create(:contact_with_name_email, user: other_school_admin, school: other_school_admin.school) }

        before do
          visit school_users_path(school)
        end

        it 'can edit fields' do
          expect(page).to have_content('Other admin')
          within '#school_admin' do
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
            within '#school_admin' do
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
          visit school_users_path(school)
          within '#school_admin' do
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

    it 'can view profile' do
      within('#staff') do
        expect(page).to have_link(staff.name, href: user_path(staff))
      end
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

    it 'can disable users' do
      within('#staff') { click_on 'Disable' }
      expect(staff.reload.active).to be(false)
    end

    it 'can unlock users' do
      staff.lock_access!(send_instructions: false)
      refresh
      within('#staff') { click_on 'Unlock' }
      expect(staff.reload.locked_at).to be_nil
    end

    it 'can disable pupils' do
      within('#pupil') { click_on 'Disable' }
      expect(pupil.reload.active).to be(false)
    end

    it 'can unlock pupils' do
      pupil.lock_access!(send_instructions: false)
      refresh
      within('#pupil') { click_on 'Unlock' }
      expect(pupil.reload.locked_at).to be_nil
    end
  end
end
