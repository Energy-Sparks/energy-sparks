# frozen_string_literal: true

RSpec.shared_examples 'a displayed issue' do
  it 'displays issue' do
    expect(page).to have_text issue.issue_type.capitalize
    expect(page).to have_text issue.title
    expect(page).to have_text issue.description.to_plain_text
    expect(page).to have_text issue.fuel_type.capitalize
    issue.meters.each do |meter|
      expect(page).to have_link meter.mpan_mprn.to_s, href: school_meter_path(meter.school, meter)
    end
    issue.issue_tags.each do |tag|
      expect(page).to have_text tag.label
    end
    expect(page).to have_text issue.status.capitalize
    expect(page).to have_text issue_admin.display_name
    expect(page).to have_text "Updated • #{user.display_name} • #{nice_date_times_today(issue.updated_at)}"
    expect(page).to have_text "Created • #{user.display_name} • #{nice_date_times_today(issue.created_at)}"
    expect(page).to have_css("i[class*='fa-thumbtack']") if issue.pinned?
  end
end

RSpec.shared_examples 'a displayed list issue' do |type: 'Filter'|
  it 'displays issue', if: type == 'Filter' do
    expect(page).to have_link(issue.title, href: polymorphic_path([:admin, issue.issueable, issue]))
    expect(page).to have_text issue.issueable.name
    expect(page).to have_text issue.fuel_type.capitalize
    issue.meters.each do |meter|
      expect(page).to have_link meter.mpan_mprn, href: school_meter_path(meter.school, meter)
    end
    issue.issue_tags.each do |tag|
      expect(page).to have_text tag.label
    end
    expect(page).to have_text nice_date_times_today(issue.updated_at)
    expect(page).to have_css("i[class*='fa-thumbtack']") if issue.pinned?
  end

  it 'displays csv issue', if: type == 'CSV' do
    expect(page).to have_text(issue.title)
    expect(page).to have_text issue.issueable.name
    expect(page).to have_text issue.fuel_type
    issue.meters.each do |meter|
      expect(page).to have_text meter.mpan_mprn
    end
    issue.issue_tags.each do |tag|
      expect(page).to have_text tag.label
    end
    expect(page).to have_text issue.updated_at
  end

  it "doesn't show other issues", if: defined? all_issues do
    all_issues - [issue].each do |issue|
      expect(page).not_to have_text issue.title
    end
  end
end
