RSpec.shared_examples 'a school group advice page' do |index: true|
  it 'displays the right breadcrumb', if: index do
    expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq([I18n.t('common.schools'), school_group.name, breadcrumb])
  end

  it 'displays the right breadcrumb', unless: index do
    expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq([I18n.t('common.schools'),
                                                                         school_group.name,
                                                                         I18n.t('advice_pages.breadcrumbs.root'),
                                                                         breadcrumb])
  end

  it 'has the expected navigation' do
    expect(page).to have_css('#group-advice-page-nav')
    within('#group-advice-page-nav') do
      expect(page).to have_link(I18n.t('advice_pages.nav.overview'), href: school_group_advice_path(school_group))
    end
  end

  it 'has the correct title' do
    expect(page).to have_content(title)
  end
end

RSpec.shared_examples 'it exports a group CSV correctly' do
  it 'the file has the expected name' do
    header = page.response_headers['Content-Disposition']
    expect(header).to match(/^attachment/)
    "#{I18n.t('common.application').parameterize}-#{school_group.name.parameterize}-#{action_name.parameterize}-#{Time.current.iso8601.tr(':', '-')}.csv"
  end

  it 'the file has the expected content' do
    expect(CSV.parse(page.body, liberal_parsing: true)).to eq(expected_csv)
  end
end
