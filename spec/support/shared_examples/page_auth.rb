RSpec.shared_examples 'the page requires a login' do
  it { expect(page).to have_content(I18n.t('devise.sessions.new.title')) }
end

RSpec.shared_examples 'the user is not authorised' do
  it { expect(page).to have_content('You are not authorized to access this page') }
end
