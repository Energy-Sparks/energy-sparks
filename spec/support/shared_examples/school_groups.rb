RSpec.shared_examples 'a public school group dashboard' do
  it 'allows user to navigate to all tabs' do
    visit map_school_group_path(school_group)
    expect(page).to have_current_path "/school_groups/#{school_group.slug}/map", ignore_query: true
    visit comparisons_school_group_path(school_group)
    expect(page).to have_current_path "/school_groups/#{school_group.slug}/comparisons", ignore_query: true
    visit priority_actions_school_group_path(school_group)
    expect(page).to have_current_path "/school_groups/#{school_group.slug}/priority_actions", ignore_query: true
    visit current_scores_school_group_path(school_group)
    expect(page).to have_current_path "/school_groups/#{school_group.slug}/current_scores", ignore_query: true
  end
end

RSpec.shared_examples 'a private school group dashboard' do
  it 'the user can only access the map view' do
    visit map_school_group_path(school_group)
    expect(page).to have_current_path "/school_groups/#{school_group.slug}/map", ignore_query: true
    visit comparisons_school_group_path(school_group)
    expect(page).to have_current_path "/school_groups/#{school_group.slug}/map", ignore_query: true
    visit priority_actions_school_group_path(school_group)
    expect(page).to have_current_path "/school_groups/#{school_group.slug}/map", ignore_query: true
    visit current_scores_school_group_path(school_group)
    expect(page).to have_current_path "/school_groups/#{school_group.slug}/map", ignore_query: true
    expect(page).to have_no_content('View group')
  end
end

RSpec.shared_examples 'school group no dashboard notification' do
  it 'does not show a school group dashboard notification' do
    visit map_school_group_path(school_group)
    expect(page).to have_no_content('A school group notice message')
    visit comparisons_school_group_path(school_group)
    expect(page).to have_no_content('A school group notice message')
    visit priority_actions_school_group_path(school_group)
    expect(page).to have_no_content('A school group notice message')
    visit current_scores_school_group_path(school_group)
    expect(page).to have_no_content('A school group notice message')
  end
end

RSpec.shared_examples 'school group dashboard notification' do
  it 'shows a school group dashboard notification' do
    visit map_school_group_path(school_group)
    expect(page).to have_content('A school group notice message')
    visit comparisons_school_group_path(school_group)
    expect(page).to have_content('A school group notice message')
    visit priority_actions_school_group_path(school_group)
    expect(page).to have_content('A school group notice message')
    visit current_scores_school_group_path(school_group)
    expect(page).to have_content('A school group notice message')
  end
end

RSpec.shared_examples 'school dashboard navigation' do
  it 'shows navigation' do
    expect(page).to have_content('Recent Usage')
    expect(page).to have_content('Comparisons')
    expect(page).to have_content('Priority Actions')
    expect(page).to have_content('Current Scores')
    expect(page).to have_content('View map')
    expect(page).to have_no_content('View group')
    expect(page).to have_content('Scoreboard')
  end

  it 'has expected path' do
    expect(page).to have_current_path expected_path, ignore_query: true
  end

  it 'shows right breadcrumb' do
    expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(['Schools', school_group.name, breadcrumb])
  end
end

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

RSpec.shared_examples 'shows the we are working with message' do
  it 'shows the we are working with message' do
    { general: 'group', local_authority: 'local authority',
      multi_academy_trust: 'multi-academy trust' }.each do |group_type, label|
      allow_any_instance_of(SchoolGroup).to receive_messages(
        {
          group_type: group_type,
          visible_schools_count: 0,
          partners: []
        }
      )
      visit school_group_path(school_group)
      expect(page).to have_content("We are working with 0 schools in this #{label}.")

      allow_any_instance_of(SchoolGroup).to receive_messages(
        {
          group_type: group_type,
          visible_schools_count: 1,
          partners: []
        }
      )
      visit school_group_path(school_group)
      expect(page).to have_content("We are working with 1 school in this #{label}.")

      allow_any_instance_of(SchoolGroup).to receive_messages(
        {
          group_type: group_type,
          visible_schools_count: 3,
          partners: []
        }
      )
      visit school_group_path(school_group)
      expect(page).to have_content("We are working with 3 schools in this #{label}.")

      allow_any_instance_of(SchoolGroup).to receive_messages(
        {
          group_type: group_type,
          visible_schools_count: 0,
          partners: [
            create(:partner, name: 'Partner 1', url: 'http://example.com'),
            create(:partner, name: 'Partner 2', url: 'http://example.com')
          ]
        }
      )
      visit school_group_path(school_group)
      expect(page).to have_content("We are working with 0 schools in this #{label} in partnership with Partner 1 and Partner 2.")

      allow_any_instance_of(SchoolGroup).to receive_messages(
        {
          group_type: group_type,
          visible_schools_count: 1,
          partners: [
            create(:partner, name: 'Partner 1', url: 'http://example.com'),
            create(:partner, name: 'Partner 2', url: 'http://example.com')
          ]
        }
      )
      visit school_group_path(school_group)
      expect(page).to have_content("We are working with 1 school in this #{label} in partnership with Partner 1 and Partner 2.")

      allow_any_instance_of(SchoolGroup).to receive_messages(
        {
          group_type: group_type,
          visible_schools_count: 3,
          partners: [
            create(:partner, name: 'Partner 1', url: 'http://example.com'),
            create(:partner, name: 'Partner 2', url: 'http://example.com')
          ]
        }
      )
      visit school_group_path(school_group)
      expect(page).to have_content("We are working with 3 schools in this #{label} in partnership with Partner 1 and Partner 2.")
    end

    visit map_school_group_path(school_group)
    expect(page).to have_content('We are working with')
    visit comparisons_school_group_path(school_group)
    expect(page).to have_content('We are working with')
    visit priority_actions_school_group_path(school_group)
    expect(page).to have_content('We are working with')
    visit current_scores_school_group_path(school_group)
    expect(page).to have_content('We are working with')
  end
end

RSpec.shared_examples 'a page not showing the cluster column' do
  it "doesn't show the cluster column" do
    expect(page).to have_no_content('Cluster')
    expect(page).to have_no_content('Not set')
  end
end

RSpec.shared_examples 'a page showing the cluster column' do
  it { expect(page).to have_content('Cluster') }

  context 'school does not have a cluster' do
    let(:cluster) {}

    it { expect(page).to have_content('Not set') }
  end

  context 'with a school in a cluster' do
    let(:cluster) { create(:school_group_cluster, name: 'My Cluster', schools: [school]) }

    it { expect(page).to have_content('My Cluster') }
  end
end

RSpec.shared_examples 'a page not showing the cluster column in the download' do
  context 'Clicking the Download as CSV link' do
    before do
      all(:link, 'Download as CSV').last.click
    end

    it { expect(page.source).to have_no_content ',Cluster,' }
  end
end

RSpec.shared_examples 'a page showing the cluster column in the download' do
  context 'Clicking the Download as CSV link' do
    before do
      all(:link, 'Download as CSV').last.click
    end

    it { expect(page.source).to have_content ',Cluster,' }
  end
end

RSpec.shared_examples 'school group tabs showing the cluster column' do
  let!(:cluster) {} # hook to create cluster before page loads if there is one

  context 'recent usage tab' do
    let!(:school) { school_group.schools.first }

    before do
      visit school_group_path(school_group)
    end

    it_behaves_like 'a page showing the cluster column'
    it_behaves_like 'a page showing the cluster column in the download'
  end

  context 'comparisons tab' do
    let!(:school) { school_1 }

    include_context 'school group comparisons'
    before do
      visit comparisons_school_group_path(school_group)
    end

    it_behaves_like 'a page showing the cluster column'
    it_behaves_like 'a page showing the cluster column in the download'
  end

  context 'priority actions tab' do
    let!(:school) { school_1 }

    include_context 'school group priority actions'
    before do
      visit priority_actions_school_group_path(school_group)
    end

    it_behaves_like 'a page showing the cluster column'
    it_behaves_like 'a page showing the cluster column in the download'
  end

  context 'current scores tab' do
    let!(:school) { school_group.schools.first }

    before do
      visit current_scores_school_group_path(school_group)
    end

    it_behaves_like 'a page showing the cluster column'
    it_behaves_like 'a page showing the cluster column in the download'
  end
end

RSpec.shared_examples 'school group tabs not showing the cluster column' do
  context 'recent usage tab' do
    before do
      visit school_group_path(school_group)
    end

    it_behaves_like 'a page not showing the cluster column'
    it_behaves_like 'a page not showing the cluster column in the download'
  end

  context 'comparisons tab' do
    include_context 'school group comparisons'
    before do
      visit comparisons_school_group_path(school_group)
    end

    it_behaves_like 'a page not showing the cluster column'
    it_behaves_like 'a page not showing the cluster column in the download'
  end

  context 'priority actions tab' do
    include_context 'school group priority actions'
    before do
      visit priority_actions_school_group_path(school_group)
    end

    it_behaves_like 'a page not showing the cluster column'
    it_behaves_like 'a page not showing the cluster column in the download'
  end

  context 'current scores tab' do
    before do
      visit current_scores_school_group_path(school_group)
    end

    it_behaves_like 'a page not showing the cluster column'
    it_behaves_like 'a page not showing the cluster column in the download'
  end
end

RSpec.shared_examples 'a page with a recent usage table' do
  it 'has correct table header' do
    within '.advice-table' do
      expect(page).to have_content('Electricity')
      expect(page).to have_content('Gas')
      expect(page).to have_content('Storage heaters')
      expect(page).to have_content('School')
      expect(page).to have_content('Last week')
      expect(page).to have_content('Last year')
    end
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
