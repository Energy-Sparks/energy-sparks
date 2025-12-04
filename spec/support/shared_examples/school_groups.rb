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

RSpec.shared_examples 'a page with a manage school group menu' do
  before do
    visit path
  end

  it { expect(page).to have_selector(id: 'manage-school-group') }
end

RSpec.shared_examples 'a page without a manage school group menu' do
  before do
    visit path
  end

  it { expect(page).to have_no_selector(id: 'manage-school-group') }
end

RSpec.shared_examples 'a page with a manage school group menu including admin links' do
  before do
    visit path
  end

  it 'shows standard items and admin links' do
    expect(find_by_id('dropdown-manage-school-group').all('a').collect(&:text)).to eq(
      ['Chart settings', 'Manage clusters', 'Manage tariffs', 'Digital signage', 'SECR report', 'School engagement', 'School status',
       'Edit group', 'Set message', 'Manage users', 'Manage partners', 'Group admin']
    )
  end
end

RSpec.shared_examples 'a page with a manage school group menu not including admin links' do
  before do
    visit path
  end

  it 'shows standard items but not admin links' do
    expect(find_by_id('dropdown-manage-school-group').all('a').collect(&:text)).to \
      eq(['Chart settings', 'Manage clusters', 'Manage tariffs', 'Digital signage', 'School engagement'])
  end
end

RSpec.shared_examples 'a page with a limited manage school group menu' do
  before do
    visit path
  end

  it 'shows standard items and admin links' do
    expect(find_by_id('dropdown-manage-school-group').all('a').collect(&:text)).to eq(
      ['School engagement']
    )
  end
end

RSpec.shared_examples 'a page with a limited manage school group menu and admin links' do
  before do
    visit path
  end

  it 'shows standard items and admin links' do
    expect(find_by_id('dropdown-manage-school-group').all('a').collect(&:text)).to eq(
      ['School engagement',
       'Edit group', 'Set message', 'Manage users', 'Manage partners', 'Group admin']
    )
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
