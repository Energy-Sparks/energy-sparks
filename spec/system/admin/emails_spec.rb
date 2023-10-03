require 'rails_helper'

describe 'Emails', type: :system do
  let!(:admin)  { create(:admin) }
  let!(:school) { create(:school) }

  describe 'visiting the admin email preview path' do
    it 'allows an admin to visit the admin email page and previews' do
      sign_in(admin)
      visit admin_emails_path
      expect(current_path).to eq("/admin/emails")
      preview = ActionMailer::Preview.all.last
      visit admin_email_preview_path(preview.preview_name + '/' + preview.emails.first)
      expect(current_path).to eq("/admin/emails/" + preview.preview_name + '/' + preview.emails.first)
    end

    it 'prevents a non admin from visiting the admin email page and previews' do
      # sign_in(admin)
      visit admin_emails_path
      expect(current_path).to eq("/users/sign_in")
      preview = ActionMailer::Preview.all.last
      visit admin_email_preview_path(preview.preview_name + '/' + preview.emails.first)
      expect(current_path).to eq("/users/sign_in")
    end
  end
end
