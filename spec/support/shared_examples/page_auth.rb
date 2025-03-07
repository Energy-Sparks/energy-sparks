RSpec.shared_examples 'the page requires a login' do
  it { expect(page).to have_content(I18n.t('devise.sessions.new.title')) }
  it { expect(page).to have_css('#staff') }
  it { expect(page).to have_css('#pupil') }
end

RSpec.shared_examples 'the page requires an adult login' do
  it { expect(page).to have_content(I18n.t('devise.sessions.new.adult_title')) }
  it { expect(page).not_to have_css('#pupil') }
end


RSpec.shared_examples 'the user is not authorised' do
  it { expect(page).to have_content('You are not authorized') }
end
