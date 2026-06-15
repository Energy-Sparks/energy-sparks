RSpec.shared_examples 'a 404 error page' do
  it { expect(page.status_code).to be 404 }
  it { expect(page).to have_text '404' }
  it { expect(page).to have_text 'Page not found' }
  it { expect(page).to have_text 'Sorry, the page you are looking for does not exist' }
  it { expect(page).to have_text 'Please continue to our home page.' }
end

RSpec.shared_examples 'a 500 error page' do
  it { expect(page.status_code).to be 500 }
  it { expect(page).to have_text '500' }
  it { expect(page).to have_text 'Sorry, something has gone wrong' }
  it { expect(page).to have_text 'The Energy Sparks team have been notified' }
  it { expect(page).to have_text 'Please continue to our home page.' }
end

RSpec.shared_examples 'a 422 error page' do
  it { expect(page.status_code).to be 422 }
  it { expect(page).to have_text '422' }
  it { expect(page).to have_text 'The change you wanted was rejected' }
  it { expect(page).to have_text "Maybe you tried to change something you didn't have access to." }
  it { expect(page).to have_text 'Please continue to our home page.' }
end
