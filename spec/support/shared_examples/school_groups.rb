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
    expect(page).not_to have_content('View group')
  end
end

RSpec.shared_examples 'school group no dashboard notification' do
  it 'does not show a school group dashboard notification' do
    visit map_school_group_path(school_group)
    expect(page).not_to have_content('A school group notice message')
    visit comparisons_school_group_path(school_group)
    expect(page).not_to have_content('A school group notice message')
    visit priority_actions_school_group_path(school_group)
    expect(page).not_to have_content('A school group notice message')
    visit current_scores_school_group_path(school_group)
    expect(page).not_to have_content('A school group notice message')
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
    expect(page).not_to have_content('View group')
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
  it 'redirects to ' do
    visit school_group_chart_updates_path(school_group)
    expect(page).to have_current_path(map_school_group_path(school_group), ignore_query: true)
  end
end

RSpec.shared_examples 'visiting chart updates redirects to group page' do
  it 'redirects to ' do
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
    expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(['Schools', school_group.name, 'Chart settings'])
    expect(page).to have_selector(id: 'school-list-menu')
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

RSpec.shared_examples 'shows the sub navigation menu' do
  it 'shows the sub navigation menu' do
    visit school_group_path(school_group)
    expect(page).to have_selector(id: 'school-group-subnav')
    expect(page).to have_selector(id: 'school-list-menu')
    expect(school_group.schools.visible.count.positive?).to eq(true)
    expect(find('#dropdown-school-list-menu').all('a').collect(&:text).sort).to eq(school_group.schools.visible.order(:name).map(&:name))
    expect(page).to have_selector(id: 'manage-school-group')

    visit map_school_group_path(school_group)
    expect(page).to have_selector(id: 'school-group-subnav')
    expect(page).to have_selector(id: 'school-list-menu')
    expect(school_group.schools.visible.count.positive?).to eq(true)
    expect(find('#dropdown-school-list-menu').all('a').collect(&:text).sort).to eq(school_group.schools.visible.order(:name).map(&:name))
    expect(page).to have_selector(id: 'manage-school-group')

    visit comparisons_school_group_path(school_group)
    expect(page).to have_selector(id: 'school-group-subnav')
    expect(page).to have_selector(id: 'school-list-menu')
    expect(school_group.schools.visible.count.positive?).to eq(true)
    expect(find('#dropdown-school-list-menu').all('a').collect(&:text).sort).to eq(school_group.schools.visible.order(:name).map(&:name))
    expect(page).to have_selector(id: 'manage-school-group')

    visit priority_actions_school_group_path(school_group)
    expect(page).to have_selector(id: 'school-group-subnav')
    expect(page).to have_selector(id: 'school-list-menu')
    expect(school_group.schools.visible.count.positive?).to eq(true)
    expect(find('#dropdown-school-list-menu').all('a').collect(&:text).sort).to eq(school_group.schools.visible.order(:name).map(&:name))
    expect(page).to have_selector(id: 'manage-school-group')

    visit current_scores_school_group_path(school_group)
    expect(page).to have_selector(id: 'school-group-subnav')
    expect(page).to have_selector(id: 'school-list-menu')
    expect(school_group.schools.visible.count.positive?).to eq(true)
    expect(find('#dropdown-school-list-menu').all('a').collect(&:text).sort).to eq(school_group.schools.visible.order(:name).map(&:name))
    expect(page).to have_selector(id: 'manage-school-group')
  end
end

RSpec.shared_examples 'does not show the sub navigation menu' do
  it 'does not show the sub navigation menu' do
    visit school_group_path(school_group)
    expect(page).not_to have_selector(id: 'school-list-menu')
    expect(page).not_to have_selector(id: 'manage-school-group')

    visit map_school_group_path(school_group)
    expect(page).not_to have_selector(id: 'school-list-menu')
    expect(page).not_to have_selector(id: 'manage-school-group')

    visit comparisons_school_group_path(school_group)
    expect(page).not_to have_selector(id: 'school-list-menu')
    expect(page).not_to have_selector(id: 'manage-school-group')

    visit priority_actions_school_group_path(school_group)
    expect(page).not_to have_selector(id: 'school-list-menu')
    expect(page).not_to have_selector(id: 'manage-school-group')

    visit current_scores_school_group_path(school_group)
    expect(page).not_to have_selector(id: 'school-list-menu')
    expect(page).not_to have_selector(id: 'manage-school-group')
  end
end

RSpec.shared_examples 'shows the we are working with message' do
  it 'shows the we are working with message' do
    { general: 'group', local_authority: 'local authority', multi_academy_trust: 'multi-academy trust' }.each do |group_type, label|
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
            OpenStruct.new(name: 'Partner 1', url: 'http://example.com'),
            OpenStruct.new(name: 'Partner 2', url: 'http://example.com')
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
            OpenStruct.new(name: 'Partner 1', url: 'http://example.com'),
            OpenStruct.new(name: 'Partner 2', url: 'http://example.com')
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
            OpenStruct.new(name: 'Partner 1', url: 'http://example.com'),
            OpenStruct.new(name: 'Partner 2', url: 'http://example.com')
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
    expect(page).not_to have_content('Cluster')
    expect(page).not_to have_content('Not set')
  end
end

RSpec.shared_examples 'a page showing the cluster column' do
  it { expect(page).to have_content('Cluster') }

  context 'school does not have a cluster' do
    let(:cluster) { }

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

    it { expect(page.source).not_to have_content ',Cluster,' }
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

# TODO improve this to check
RSpec.shared_examples 'a school group recent usage tab' do
  it 'shows % changes in the table by default' do
    visit school_group_path(school_group, {})
    expect(page).to have_content('Electricity')
    expect(page).to have_content('Gas')
    expect(page).to have_content('Storage heaters')
    expect(page).to have_content('School')
    expect(page).to have_content('Last week')
    expect(page).to have_content('Last year')
    expect(page).to have_content('-16%')
    expect(page).not_to have_content('910')
    expect(page).not_to have_content('£137')
    expect(page).not_to have_content('8,540')
  end

  describe 'when metrics params are included in url' do
    it 'shows expected table content for change when there is an invalid params' do
      visit school_group_path(school_group, metric: 'something invalid')
      expect(page).to have_content('Electricity')
      expect(page).to have_content('Gas')
      expect(page).to have_content('Storage heaters')
      expect(page).to have_content('School')
      expect(page).to have_content('Last week')
      expect(page).to have_content('Last year')
      expect(page).to have_content('-16%')
      expect(page).not_to have_content('910')
      expect(page).not_to have_content('£137')
      expect(page).not_to have_content('8,540')
    end

    it 'shows expected table content when % change is requested' do
      visit school_group_path(school_group, metrics: 'change')
      expect(page).to have_content('Electricity')
      expect(page).to have_content('Gas')
      expect(page).to have_content('Storage heaters')
      expect(page).to have_content('School')
      expect(page).to have_content('Last week')
      expect(page).to have_content('Last year')
      expect(page).to have_content('-16%')
      expect(page).not_to have_content('910')
      expect(page).not_to have_content('£137')
      expect(page).not_to have_content('8,540')
    end

    it 'shows expected table content when usage is requested' do
      visit school_group_path(school_group, metric: 'usage')
      expect(page).to have_content('Electricity')
      expect(page).to have_content('Gas')
      expect(page).to have_content('Storage heaters')
      expect(page).to have_content('School')
      expect(page).to have_content('Last week')
      expect(page).to have_content('Last year')
      expect(page).not_to have_content('-16%')
      expect(page).to have_content('910')
      expect(page).not_to have_content('£137')
      expect(page).not_to have_content('8,540')
    end

    it 'shows expected table content when cost is requested' do
      visit school_group_path(school_group, metric: 'cost')
      expect(page).to have_content('Electricity')
      expect(page).to have_content('Gas')
      expect(page).to have_content('Storage heaters')
      expect(page).to have_content('School')
      expect(page).to have_content('Last week')
      expect(page).to have_content('Last year')
      expect(page).not_to have_content('-16%')
      expect(page).not_to have_content('910')
      expect(page).to have_content('£137')
      expect(page).not_to have_content('8,540')
    end

    it 'shows expected table content when co2 is requested' do
      visit school_group_path(school_group, metric: 'co2')
      expect(page).to have_content('Electricity')
      expect(page).to have_content('Gas')
      expect(page).to have_content('Storage heaters')
      expect(page).to have_content('School')
      expect(page).to have_content('Last week')
      expect(page).to have_content('Last year')
      expect(page).not_to have_content('-16%')
      expect(page).not_to have_content('910')
      expect(page).not_to have_content('£137')
      expect(page).to have_content('8,540')
    end
  end
end
