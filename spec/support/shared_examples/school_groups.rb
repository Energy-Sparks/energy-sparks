RSpec.shared_examples "a public school group dashboard" do
  it 'allows user to navigate to all tabs' do
    visit map_school_group_path(school_group)
    expect(current_path).to eq "/school_groups/#{school_group.slug}/map"
    visit comparisons_school_group_path(school_group)
    expect(current_path).to eq "/school_groups/#{school_group.slug}/comparisons"
    visit priority_actions_school_group_path(school_group)
    expect(current_path).to eq "/school_groups/#{school_group.slug}/priority_actions"
    visit current_scores_school_group_path(school_group)
    expect(current_path).to eq "/school_groups/#{school_group.slug}/current_scores"
  end
end

RSpec.shared_examples "a private school group dashboard" do
  it 'the user can only access the map view' do
    visit map_school_group_path(school_group)
    expect(current_path).to eq "/school_groups/#{school_group.slug}/map"
    visit comparisons_school_group_path(school_group)
    expect(current_path).to eq "/school_groups/#{school_group.slug}/map"
    visit priority_actions_school_group_path(school_group)
    expect(current_path).to eq "/school_groups/#{school_group.slug}/map"
    visit current_scores_school_group_path(school_group)
    expect(current_path).to eq "/school_groups/#{school_group.slug}/map"
    expect(page).to_not have_content('View group')
  end
end

RSpec.shared_examples "school group no dashboard notification" do
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

RSpec.shared_examples "school group dashboard notification" do
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

RSpec.shared_examples "school dashboard navigation" do
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
    expect(current_path).to eq expected_path
  end

  it 'shows right breadcrumb' do
    expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(['Schools', school_group.name, breadcrumb])
  end
end

RSpec.shared_examples "visiting chart updates redirects to group map page" do
  it 'redirects to ' do
    visit school_group_chart_updates_path(school_group)
    expect(current_path).to eq(map_school_group_path(school_group))
  end
end

RSpec.shared_examples "visiting chart updates redirects to group page" do
  it 'redirects to ' do
    visit school_group_chart_updates_path(school_group)
    expect(current_path).to eq(school_group_path(school_group))
  end
end

RSpec.shared_examples "redirects to school group page" do
  it 'redirects to school group page' do
    expect(page).to have_current_path "/school_groups/#{school_group.slug}"
  end
end

RSpec.shared_examples "redirects to login page" do
  it 'redirects to login page' do
    expect(current_path).to eq("/users/sign_in")
  end
end

RSpec.shared_examples 'allows access to chart updates page and editing of default chart preferences' do
  it 'shows a form to select default chart units' do
    visit school_group_chart_updates_path(school_group)
    expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq(['Schools', school_group.name, 'Chart settings'])
    expect(page).to have_selector(id: "school-list-menu")
    expect(page).to have_selector(id: "manage-school-group")
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

RSpec.shared_examples "shows the sub navigation menu" do
  it 'shows the sub navigation menu' do
    visit school_group_path(school_group)
    expect(page).to have_selector(id: "school-group-subnav")
    expect(page).to have_selector(id: "school-list-menu")
    expect(school_group.schools.visible.count.positive?).to eq(true)
    expect(find('#dropdown-school-list-menu').all('a').collect(&:text).sort).to eq(school_group.schools.visible.order(:name).map(&:name))
    expect(page).to have_selector(id: "manage-school-group")

    visit map_school_group_path(school_group)
    expect(page).to have_selector(id: "school-group-subnav")
    expect(page).to have_selector(id: "school-list-menu")
    expect(school_group.schools.visible.count.positive?).to eq(true)
    expect(find('#dropdown-school-list-menu').all('a').collect(&:text).sort).to eq(school_group.schools.visible.order(:name).map(&:name))
    expect(page).to have_selector(id: "manage-school-group")

    visit comparisons_school_group_path(school_group)
    expect(page).to have_selector(id: "school-group-subnav")
    expect(page).to have_selector(id: "school-list-menu")
    expect(school_group.schools.visible.count.positive?).to eq(true)
    expect(find('#dropdown-school-list-menu').all('a').collect(&:text).sort).to eq(school_group.schools.visible.order(:name).map(&:name))
    expect(page).to have_selector(id: "manage-school-group")

    visit priority_actions_school_group_path(school_group)
    expect(page).to have_selector(id: "school-group-subnav")
    expect(page).to have_selector(id: "school-list-menu")
    expect(school_group.schools.visible.count.positive?).to eq(true)
    expect(find('#dropdown-school-list-menu').all('a').collect(&:text).sort).to eq(school_group.schools.visible.order(:name).map(&:name))
    expect(page).to have_selector(id: "manage-school-group")

    visit current_scores_school_group_path(school_group)
    expect(page).to have_selector(id: "school-group-subnav")
    expect(page).to have_selector(id: "school-list-menu")
    expect(school_group.schools.visible.count.positive?).to eq(true)
    expect(find('#dropdown-school-list-menu').all('a').collect(&:text).sort).to eq(school_group.schools.visible.order(:name).map(&:name))
    expect(page).to have_selector(id: "manage-school-group")
  end
end

RSpec.shared_examples "does not show the sub navigation menu" do
  it 'does not show the sub navigation menu' do
    visit school_group_path(school_group)
    expect(page).not_to have_selector(id: "school-list-menu")
    expect(page).not_to have_selector(id: "manage-school-group")

    visit map_school_group_path(school_group)
    expect(page).not_to have_selector(id: "school-list-menu")
    expect(page).not_to have_selector(id: "manage-school-group")

    visit comparisons_school_group_path(school_group)
    expect(page).not_to have_selector(id: "school-list-menu")
    expect(page).not_to have_selector(id: "manage-school-group")

    visit priority_actions_school_group_path(school_group)
    expect(page).not_to have_selector(id: "school-list-menu")
    expect(page).not_to have_selector(id: "manage-school-group")

    visit current_scores_school_group_path(school_group)
    expect(page).not_to have_selector(id: "school-list-menu")
    expect(page).not_to have_selector(id: "manage-school-group")
  end
end

RSpec.shared_examples "shows the we are working with message" do
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

RSpec.shared_examples "not showing the cluster column" do
  before do
    visit url if defined?(url)
  end
  it "doesn't show the cluster column" do
    expect(page).to_not have_content('Cluster')
    expect(page).to_not have_content('Not set')
  end
end

RSpec.shared_examples "showing the cluster column" do
  let!(:cluster) {}
  before do
    visit url if defined?(url)
  end
  it { expect(page).to have_content('Cluster') }

  context "school does not have a cluster" do
    it { expect(page).to have_content('Not set') }
  end

  context "school is in a cluster" do
    let!(:cluster) { create(:school_group_cluster, name: "My Cluster", schools: [school]) }
    it { expect(page).to have_content('My Cluster') }
  end
end

RSpec.shared_examples "not showing the cluster column in the download" do
  context "Clicking the Download as CSV link" do
    before do
      all(:link, 'Download as CSV').last.click
    end
    it { expect(page.source).to_not have_content ",Cluster," }
  end
end

RSpec.shared_examples "showing the cluster column in the download" do
  context "Clicking the Download as CSV link" do
    before do
      all(:link, 'Download as CSV').last.click
    end
    it { expect(page.source).to have_content ",Cluster," }
  end
end
