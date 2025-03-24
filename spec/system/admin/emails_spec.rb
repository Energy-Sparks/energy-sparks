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

  describe 'visiting the admin email preview path' do
    context 'as an admin' do
      it 'lets the user see the email preview page' do
        sign_in(admin)
        visit admin_mailer_previews_path
        expect(page).to have_current_path('/admin/mailer_previews', ignore_query: true)
        preview = ActionMailer::Preview.all.last
        visit admin_mailer_preview_path(preview.preview_name)
        expect(page).to have_current_path('/admin/mailer_previews/' + preview.preview_name, ignore_query: true)
        visit admin_mailer_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(page).to have_current_path('/admin/mailer_previews/' + preview.preview_name + '/' + preview.emails.first, ignore_query: true)
      end
    end

    context 'with no signed in user' do
      it 'prevents the user from seeing the admin email preview page' do
        visit admin_mailer_previews_path
        expect(page).to have_current_path('/users/sign_in', ignore_query: true)
        preview = ActionMailer::Preview.all.last
        visit admin_mailer_preview_path(preview.preview_name)
        expect(page).to have_current_path('/users/sign_in', ignore_query: true)
        visit admin_mailer_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(page).to have_current_path('/users/sign_in', ignore_query: true)
      end
    end

    context 'as a group_admin user' do
      it 'prevents the user from seeing the admin email preview page' do
        sign_in(group_admin)
        visit admin_mailer_previews_path
        expect(page).to have_current_path("/school_groups/#{group_admin.school_group.slug}/map", ignore_query: true)
        preview = ActionMailer::Preview.all.last
        visit admin_mailer_preview_path(preview.preview_name)
        expect(page).to have_current_path("/school_groups/#{group_admin.school_group.slug}/map", ignore_query: true)
        visit admin_mailer_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(page).to have_current_path("/school_groups/#{group_admin.school_group.slug}/map", ignore_query: true)
      end
    end

    context 'as a guest user' do
      it 'prevents the user from seeing the admin email preview page' do
        sign_in(guest)
        visit admin_mailer_previews_path
        expect(page).to have_current_path('/schools', ignore_query: true)
        preview = ActionMailer::Preview.all.last
        visit admin_mailer_preview_path(preview.preview_name)
        expect(page).to have_current_path('/schools', ignore_query: true)
        visit admin_mailer_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(page).to have_current_path('/schools', ignore_query: true)
      end
    end

    context 'as a pupil user' do
      it 'prevents the user from seeing the admin email preview page' do
        sign_in(pupil)
        visit admin_mailer_previews_path
        expect(page).to have_current_path("/pupils/schools/#{school.slug}", ignore_query: true)
        preview = ActionMailer::Preview.all.last
        visit admin_mailer_preview_path(preview.preview_name)
        expect(page).to have_current_path("/pupils/schools/#{school.slug}", ignore_query: true)
        visit admin_mailer_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(page).to have_current_path("/pupils/schools/#{school.slug}", ignore_query: true)
      end
    end

    context 'as a school_onboarding user' do
      it 'prevents the user from seeing the admin email preview page' do
        sign_in(onboarding_user)
        visit admin_mailer_previews_path
        expect(page).to have_current_path("/schools/#{school.slug}", ignore_query: true)
        preview = ActionMailer::Preview.all.last
        visit admin_mailer_preview_path(preview.preview_name)
        expect(page).to have_current_path("/schools/#{school.slug}", ignore_query: true)
        visit admin_mailer_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(page).to have_current_path("/schools/#{school.slug}", ignore_query: true)
      end
    end

    context 'as a staff user' do
      it 'prevents the user from seeing the admin email preview page' do
        sign_in(staff)
        visit admin_mailer_previews_path
        expect(page).to have_current_path("/schools/#{school.slug}", ignore_query: true)
        preview = ActionMailer::Preview.all.last
        visit admin_mailer_preview_path(preview.preview_name)
        expect(page).to have_current_path("/schools/#{school.slug}", ignore_query: true)
        visit admin_mailer_preview_path(preview.preview_name + '/' + preview.emails.first)
        expect(page).to have_current_path("/schools/#{school.slug}", ignore_query: true)
      end
    end
  end
end
