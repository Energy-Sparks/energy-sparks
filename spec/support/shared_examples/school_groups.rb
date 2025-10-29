RSpec.shared_examples 'visiting chart updates redirects to group map page' do
  it 'redirects to' do
    visit school_group_chart_updates_path(school_group)
    expect(page).to have_current_path(map_school_group_path(school_group), ignore_query: true)
  end
end

RSpec.shared_examples 'visiting chart updates redirects to group page' do
  it 'redirects to' do
    visit school_group_chart_updates_path(school_group)
    expect(page).to have_current_path(school_group_path(school_group), ignore_query: true)
  end
end

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

RSpec.shared_examples 'allows access to chart updates page and editing of default chart preferences' do
  it 'shows a form to select default chart units' do
    visit school_group_chart_updates_path(school_group)
    expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(['Schools', school_group.name,
                                                                         'Chart settings'])
    expect(page).to have_selector(id: 'manage-school-group')
    expect(school_group.default_chart_preference).to eq('default')
    expect(school_group2.default_chart_preference).to eq('default')
    expect(school_group.schools.map(&:chart_preference).sort).to eq(%w[carbon default usage])
    expect(school_group2.schools.map(&:chart_preference).sort).to eq(%w[carbon default usage])
    expect(page).to have_content("#{school_group.name} chart settings")
    SchoolGroup.default_chart_preferences.each_key do |preference|
      expect(page).to have_content(I18n.t("school_groups.chart_updates.index.default_chart_preference.#{preference}"))
    end
    choose 'Display chart data in £, where available'
    click_on 'Update all schools in this group'
    expect(school_group.reload.default_chart_preference).to eq('cost')
    expect(school_group2.reload.default_chart_preference).to eq('default')
    expect(school_group.schools.map(&:chart_preference).sort).to eq(%w[cost cost cost])
    expect(school_group2.schools.map(&:chart_preference).sort).to eq(%w[carbon default usage])
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
      ['Chart settings', 'Manage clusters', 'Manage tariffs', 'Digital signage', 'SECR report', 'School engagement',
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

RSpec.shared_examples 'schools are filtered by permissions' do |admin: false, school_admin: false|
  let(:data_sharing) { :within_group }
  let!(:filtered_school) { create(:school, school_group: school_group, data_sharing: data_sharing) }

  before do
    visit school_group_path(school_group)
  end

  context 'with data sharing set to within_group' do
    it 'does not show the school', unless: admin || school_admin do
      expect(page).to have_no_content(filtered_school.name)
    end

    it 'shows all the schools', if: admin || school_admin do
      expect(page).to have_content(filtered_school.name)
    end
  end

  context 'with data sharing set to private' do
    let(:data_sharing) { :private }

    it 'does not show the school', unless: admin do
      expect(page).to have_no_content(filtered_school.name)
    end

    it 'shows all the schools', if: admin do
      expect(page).to have_content(filtered_school.name)
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
