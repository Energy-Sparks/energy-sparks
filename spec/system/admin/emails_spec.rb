require 'rails_helper'

describe 'Emails', type: :system do
  let!(:school) { create(:school) }
  let!(:admin)  { create(:admin) }
  let!(:school_admin) { create(:school_admin, school: school) }
  let!(:group_admin) { create(:group_admin) }
  let!(:guest) { create(:guest) }
  let!(:pupil) { create(:pupil, school: school) }
  let!(:onboarding_user) { create(:onboarding_user, school: school) }
  let!(:staff) { create(:staff, school: school) }
  let!(:volunteer) { create(:volunteer, school: school) }

  describe 'visiting the admin email preview path' do
    context 'as an admin' do
      it 'lets the user see the email preview page' do
        sign_in(admin)
        visit admin_emails_path
        expect(current_path).to eq("/admin/emails")
        preview = ActionMailer::Preview.all.last
        visit admin_email_preview_path(preview.preview_name)
        expect(current_path).to eq("/admin/emails/" + preview.preview_name)
        visit admin_email_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(current_path).to eq("/admin/emails/" + preview.preview_name + '/' + preview.emails.first)
      end
    end

    context 'with no signed in user' do
      it 'prevents the user from seeing the admin email preview page' do
        visit admin_emails_path
        expect(current_path).to eq("/users/sign_in")
        preview = ActionMailer::Preview.all.last
        visit admin_email_preview_path(preview.preview_name)
        expect(current_path).to eq("/users/sign_in")
        visit admin_email_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(current_path).to eq("/users/sign_in")
      end
    end

    context 'as a group_admin user' do
      it 'prevents the user from seeing the admin email preview page' do
        sign_in(group_admin)
        visit admin_emails_path
        expect(current_path).to eq("/school_groups/#{group_admin.school_group.slug}")
        preview = ActionMailer::Preview.all.last
        visit admin_email_preview_path(preview.preview_name)
        expect(current_path).to eq("/school_groups/#{group_admin.school_group.slug}")
        visit admin_email_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(current_path).to eq("/school_groups/#{group_admin.school_group.slug}")
      end
    end

    context 'as a guest user' do
      it 'prevents the user from seeing the admin email preview page' do
        sign_in(guest)
        visit admin_emails_path
        expect(current_path).to eq("/schools")
        preview = ActionMailer::Preview.all.last
        visit admin_email_preview_path(preview.preview_name)
        expect(current_path).to eq("/schools")
        visit admin_email_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(current_path).to eq("/schools")
      end
    end

    context 'as a pupil user' do
      it 'prevents the user from seeing the admin email preview page' do
        sign_in(pupil)
        visit admin_emails_path
        expect(current_path).to eq("/pupils/schools/#{school.slug}")
        preview = ActionMailer::Preview.all.last
        visit admin_email_preview_path(preview.preview_name)
        expect(current_path).to eq("/pupils/schools/#{school.slug}")
        visit admin_email_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(current_path).to eq("/pupils/schools/#{school.slug}")
      end
    end

    context 'as a school_onboarding user' do
      it 'prevents the user from seeing the admin email preview page' do
        sign_in(onboarding_user)
        visit admin_emails_path
        expect(current_path).to eq("/schools/#{school.slug}")
        preview = ActionMailer::Preview.all.last
        visit admin_email_preview_path(preview.preview_name)
        expect(current_path).to eq("/schools/#{school.slug}")
        visit admin_email_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end

    context 'as a staff user' do
      it 'prevents the user from seeing the admin email preview page' do
        sign_in(staff)
        visit admin_emails_path
        expect(current_path).to eq("/schools/#{school.slug}")
        preview = ActionMailer::Preview.all.last
        visit admin_email_preview_path(preview.preview_name)
        expect(current_path).to eq("/schools/#{school.slug}")
        visit admin_email_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end

    context 'as a volunteer user' do
      it 'prevents the user from seeing the admin email preview page' do
        sign_in(volunteer)
        visit admin_emails_path
        expect(current_path).to eq("/schools/#{school.slug}")
        preview = ActionMailer::Preview.all.last
        visit admin_email_preview_path(preview.preview_name)
        expect(current_path).to eq("/schools/#{school.slug}")
        visit admin_email_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(current_path).to eq("/schools/#{school.slug}")
      end
    end
  end
end

