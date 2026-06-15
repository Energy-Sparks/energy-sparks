RSpec.shared_examples 'an advice page' do
  it 'shows advice breadcrumbs' do
    within '.page-breadcrumb' do
      expect(page).to have_link('Schools')
      expect(page).to have_link(school.name)
      expect(page).to have_link(school.school_group.name) if school.school_group
      expect(page).to have_text('Advice')
    end
  end

  it 'shows the page nav' do
    within '.advice-page-nav' do
      expect(page).to have_content(I18n.t('advice_pages.nav.overview'))
      expect(page).to have_content(I18n.t("advice_pages.nav.pages.#{key}"))
    end
  end
end

RSpec.shared_examples 'it responds to HEAD requests' do
  [:insights, :analysis, :learn_more].each do |action|
    it "return :ok with HEAD request to #{action}" do
      process :head, polymorphic_path([action, school, :advice, advice_page.key.to_sym])
      expect(response).to have_http_status(:ok)
    end
  end
end

RSpec.shared_examples 'an advice page tab' do |tab:|
  it_behaves_like 'an advice page'

  it 'shows the page title' do
    expect(page).to have_content(expected_page_title)
  end

  it 'shows page breadcrumb' do
    within '.page-breadcrumb' do
      expect(page).to have_link('Advice')
      expect(page).to have_text(expected_page_title)
    end
  end

  it "has an active #{tab} tab" do
    expect(page).to have_link(tab, class: 'active')
  end

  it "all tabs except #{tab} are inactive" do
    ['Insights', 'Analysis', 'Learn More'].excluding(tab).each do |option|
      expect(page).not_to have_link(option, class: 'active')
    end
  end

  it 'shows 410 for an inactive school' do
    school.update(active: false)
    refresh
    expect(page.status_code).to eq(410)
  end

  context 'when restricted' do
    before do
      advice_page.update(restricted: true)
      refresh
    end

    it 'still shows the analysis' do
      expect(page).to have_content(expected_page_title)
    end
  end

  context 'Learn More', if: tab == 'Learn More' do
    it 'shows learn more content' do
      within '.advice-page-tabs' do
        expect(page).to have_content(advice_page.learn_more.body.to_html)
      end
    end
  end

  context 'Insights', if: tab == 'Insights' do
    it 'shows recommendations' do
      within '.advice-page-tabs' do
        expect(page).to have_content('What should you do next?')
      end
    end
  end
end

RSpec.shared_examples 'an advice page NOT showing electricity data warning' do
  it 'does NOT show data warning' do
    expect(page).not_to have_content('We have not received data for your electricity usage for over thirty days')
  end
end

RSpec.shared_examples 'an advice page showing electricity data warning' do
  it 'does show data warning' do
    expect(page).to have_content('We have not received data for your electricity usage for over thirty days')
  end
end

RSpec.shared_examples 'an advice page with an alert notice' do |link: false|
  it 'shows the notice' do
    within('.alerts-component') do
      expect(page).to have_content(expected_notice)
    end
  end

  it 'has a link in the notice', if: link do
    within('.alerts-component') do
      expect(page).to have_link('View analysis')
    end
  end
end
