RSpec.shared_examples_for 'a displayed issue' do
  it 'displays issue' do
    expect(page).to have_content issue.issue_type.capitalize
    expect(page).to have_content issue.title
    expect(page).to have_content issue.description.to_plain_text
    expect(page).to have_content issue.fuel_type.capitalize
    issue.meters.each do |meter|
      expect(page).to have_link meter.mpan_mprn.to_s, href: school_meter_path(meter.school, meter)
    end
    expect(page).to have_content issue.status.capitalize
    expect(page).to have_content issue_admin.display_name
    expect(page).to have_content "Updated • #{user.display_name} • #{nice_date_times_today(issue.updated_at)}"
    expect(page).to have_content "Created • #{user.display_name} • #{nice_date_times_today(issue.created_at)}"
    expect(page).to have_css("i[class*='fa-thumbtack']") if issue.pinned?
  end
end

RSpec.shared_examples_for 'a displayed list issue' do
  it 'displays issue' do
    expect(page).to have_link(issue.title, href: polymorphic_path([:admin, issue.issueable, issue]))
    expect(page).to have_content issue.issueable.name
    expect(page).to have_content issue.fuel_type.capitalize
    issue.meters.each do |meter|
      expect(page).to have_link meter.mpan_mprn, href: school_meter_path(meter.school, meter)
    end
    expect(page).to have_content nice_date_times_today(issue.updated_at)
    expect(page).to have_css("i[class*='fa-thumbtack']") if issue.pinned?
  end

  it "doesn't show other issues", if: defined? all_issues do
    all_issues - [issue].each do |issue|
      expect(page).not_to have_content issue.title
    end
  end
end
