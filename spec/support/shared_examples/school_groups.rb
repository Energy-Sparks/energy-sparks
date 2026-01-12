RSpec.shared_examples 'redirects to school group page' do
  it 'redirects to school group page' do
    expect(page).to have_current_path "/school_groups/#{school_group.slug}"
  end
end

RSpec.shared_examples 'redirects to login page' do
  it 'redirects to login page' do
    expect(page).to have_current_path('/users/sign_in', ignore_query: true)
  end
end

RSpec.shared_examples 'a page without a manage school group menu or link' do
  before do
    visit path
  end

  it { expect(page).to have_no_selector(id: 'manage-school-group') }
  it { expect(page).not_to have_link('Manage group', href: settings_school_group_path(school_group)) }
end

RSpec.shared_examples 'a page with a limited manage school group menu' do
  before do
    visit path
  end

  it 'shows non-organisation group specific items and admin links' do
    expect(find_by_id('dropdown-manage-school-group').all('a').collect(&:text)).to eq(
      ['Settings', 'School engagement', 'School status', 'Timeline',
       'Edit group', 'Group admin', 'Issues', 'Manage users', 'Manage partners', 'Set message']
    )
  end
end

RSpec.shared_examples 'a page with a manage school group menu' do
  before do
    visit path
  end

  it 'shows standard items and admin links' do
    expect(find_by_id('dropdown-manage-school-group').all('a').collect(&:text)).to eq(
      ['Settings', 'Chart settings', 'Manage clusters', 'Manage tariffs',
       'Digital signage', 'School engagement', 'School status', 'SECR report', 'Timeline',
       'Edit group', 'Group admin', 'Issues', 'Manage users', 'Manage partners', 'Set message']
    )
  end
end

RSpec.shared_examples 'a page with a manage group link' do
  before do
    visit path
  end

  it 'shows link to settings page' do
    within '.navbar-second' do
      expect(page).to have_link('Manage Group', href: settings_school_group_path(school_group))
    end
  end
end

RSpec.shared_examples 'a group advice page secr nav link' do |display: true|
  it "#{display ? 'shows' : "doesn't show"} secr nav link" do
    if display
      expect(page).to have_link('SECR report', href: school_group_secr_index_path(school_group))
    else
      expect(page).to have_no_link('SECR report', href: school_group_secr_index_path(school_group))
    end
  end
end

RSpec.shared_examples 'a page with the school group settings nav' do
  it 'shows school group settings nav' do
    expect(page).to have_css('#page-nav .navigation-manage-group-component')
  end
end

RSpec.shared_examples 'a page without the school group settings nav' do
  it 'does not show school group settings nav' do
    expect(page).not_to have_css('#page-nav .navigation-manage-group-component')
  end
end
