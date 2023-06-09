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
