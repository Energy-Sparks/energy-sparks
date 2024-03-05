# frozen_string_literal: true

RSpec.shared_examples 'a school comparison report' do |school_types: nil, school_types_excluding: nil, country: nil, school_groups: nil, funder: nil|
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
        expect(page).not_to have_content(I18n.t("common.school_types.#{school_type}"))
      end
    end

    it 'displays school types', if: school_types_excluding do
      all_school_types.excluding(school_types_excluding).each do |school_type|
        expect(page).to have_content(I18n.t("common.school_types.#{school_type}"))
      end
      school_types_excluding.each do |school_type|
        expect(page).not_to have_content(I18n.t("common.school_types.#{school_type}"))
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

    it { expect(page).to have_link('Change options')}
  end
end

RSpec.shared_examples 'a school comparison report with a table' do
  let(:table_name) { :table }

  it 'links each row to the relevant advice page' do
    within('#tables') do
      within("##{expected_report.key}-#{table_name}") do
        expect(page).to have_link(expected_school.name, href: advice_page_path)
      end
    end
  end

  it 'displays the expected table' do
    expect(all("##{expected_report.key}-#{table_name} tr").map { |tr| tr.all('th,td').map(&:text) }).to eq(expected_table)
  end

  it 'links to a CSV download' do
    within('#tables') do
      expect(page).to have_link(I18n.t('school_groups.download_as_csv'))
    end
  end

  it 'downloads the expected CSV' do
    within('#tables') do
      click_on(I18n.t('school_groups.download_as_csv'))
      parsed = CSV.parse(page.body, liberal_parsing: true)
      expect(parsed).to eq(expected_csv)
    end
  end
end

RSpec.shared_examples 'a school comparison report with a chart' do
  it 'includes a chart' do
    within '#charts' do
      expect(page).to have_css('#chart_comparison')
    end
  end
end
