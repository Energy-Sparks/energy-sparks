RSpec.shared_examples 'an account page with navigation' do |admin: false|
  it { expect(page).to have_title(user.name) }

  it 'displays profile header' do
    expect(page).to have_css('#profile-header')
    within('#profile-header') do
      expect(page).to have_content(user.name)
    end
  end

  it do
    within('#profile-page-navigation') do
      expect(page).to have_link(I18n.t('nav.my_account')), href: user_path(user)
    end
  end

  it do
    within('#profile-page-navigation') do
      expect(page).to have_link(I18n.t('users.show.change_password'), href: edit_password_user_path(user))
    end
  end

  it do
    within('#profile-page-navigation') do
      expect(page).to have_link(I18n.t('users.show.update_account'), href: edit_user_path(user))
    end
  end

  it 'links to schools page', unless: admin do
    within('#profile-page-navigation') do
      expect(page).to have_link(I18n.t('users.show.manage_alerts'), href: user_contacts_path(user))
    end
  end

  it 'does not link to schools page', if: admin do
    within('#profile-page-navigation') do
      expect(page).not_to have_link(I18n.t('users.show.manage_alerts'), href: user_contacts_path(user))
    end
  end

  it 'displays links to manage emails' do
    within('#profile-page-navigation') do
      expect(page).to have_link(I18n.t('users.show.update_email_preferences'), href: user_emails_path(user))
    end
  end
end
