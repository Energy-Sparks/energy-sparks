# frozen_string_literal: true

RSpec.shared_examples 'a school comparison report' do |school_types: nil, school_types_excluding: nil, country: nil, school_groups: nil, funder: nil|
  before do
    visit "/comparisons/#{expected_report.key}"
  end

  it 'has the expected page title' do
    expect(page).to have_content(expected_report.title)
  end

  it 'has the expected report introduction' do
    expect(page).to have_content(expected_report.introduction.to_plain_text)
  end

  context 'with the filters section' do
    let(:all_school_types)  { School.school_types.keys }

    it 'displays school types', if: school_types do
      school_types.each do |school_type|
        expect(page).to have_content(I18n.t("common.school_types.#{school_type}"))
      end
      all_school_types.excluding(school_types).each do |school_type|
        expect(page).to have_no_content(I18n.t("common.school_types.#{school_type}"))
      end
    end

    it 'displays school types', if: school_types_excluding do
      all_school_types.excluding(school_types_excluding).each do |school_type|
        expect(page).to have_content(I18n.t("common.school_types.#{school_type}"))
      end
      school_types_excluding.each do |school_type|
        expect(page).to have_no_content(I18n.t("common.school_types.#{school_type}"))
      end
    end

    it 'displays country', if: country do
      expect(page).to have_content country
    end

    it 'displays groups', if: school_groups do
      school_groups.each do |group|
        expect(page).to have_content(group)
      end
    end

    it 'displays funder', if: funder do
      expect(page).to have_content funder
    end

    it { expect(page).to have_link('Change options') }
  end

  context 'with no data' do
    let(:alerts) {} # rubocop:disable Lint/EmptyBlock

    it 'works with no data' do
      # TODO: seems like this might be brittle but want to ensure the test hasn't created any alerts
      expect(Alert.count).to eq(0)
      expect(page).to have_content(expected_report.title)
    end
  end
end

RSpec.shared_examples 'a school comparison report with a table' do |visit: true|
  let(:table_name) { :table }
  let(:model) { Comparison.const_get(expected_report.key.camelize) }
  let(:path) { "/comparisons/#{expected_report.key}" }

  before do
    model.refresh
    visit path if visit
  end

  it 'links each row to the relevant advice page' do
    if defined?(advice_page_path)
      within("##{expected_report.key}-#{table_name}") do
        expect(page).to have_link(expected_school.name, href: advice_page_path)
      end
    end
  end

  it 'displays the expected table' do
    expect(all("##{expected_report.key}-#{table_name} tr").map { |tr| tr.all('th,td').map(&:text) }).to \
      eq(expected_table)
  end

  it 'downloads the expected CSV' do
    find("##{expected_report.key}-#{table_name}-download", exact_text: I18n.t('school_groups.download_as_csv')).click
    expect(CSV.parse(page.body, liberal_parsing: true)).to eq(expected_csv)
  end
end

RSpec.shared_examples 'a school comparison report with a chart' do
  let(:chart_name) { :comparison }
  let(:model) { Comparison.const_get(expected_report.key.camelize) }
  let(:path) { "/comparisons/#{expected_report.key}" }

  before do
    model.refresh
    visit path if path
  end

  it 'includes a chart' do
    within '#charts' do
      expect(page).to have_css("#chart_#{chart_name}")
    end
  end
end

RSpec.shared_examples 'a school comparison report with multiple tables' do |table_titles: nil|
  let(:model) { Comparison.const_get(expected_report.key.camelize) }

  before do
    model.refresh
    visit "/comparisons/#{expected_report.key}"
  end

  it 'includes a table of contents' do
    within '#table-list' do
      expect(page).to have_css('li', count: table_titles.size)
    end
  end

  it 'includes all table titles' do
    index = 0
    while index < table_titles.size
      expect(page).to have_css("#report-table-#{index + 1}")
      expect(page).to have_content(table_titles[index])
      index += 1
    end
  end
end
