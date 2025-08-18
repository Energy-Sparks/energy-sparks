RSpec.shared_examples 'a school group advice page' do
  it 'displays the right breadcrumb' do
    expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq([I18n.t('common.schools'), school_group.name, breadcrumb])
  end

  it 'has the expected navigation' do
    expect(page).to have_css('#group-advice-page-nav')
    within('#group-advice-page-nav') do
      expect(page).to have_link(I18n.t('advice_pages.nav.overview'), href: school_group_advice_path(school_group))
    end
  end
end

RSpec.shared_examples 'it downloads a CSV correctly' do
  it 'has the expected filename' do
    header = page.response_headers['Content-Disposition']
    expect(header).to match(/^attachment/)
    "#{I18n.t('common.application').parameterize}-#{school_group.name.parameterize}-#{action_name.parameterize}-#{Time.current.iso8601.tr(':', '-')}.csv"
  end
end
