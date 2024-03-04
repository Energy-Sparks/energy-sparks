RSpec.shared_examples 'a school comparison report' do
  it 'has the expected page title' do
    expect(page).to have_content(title)
  end

  it 'includes a chart' do
    if defined?(chart)
      within '#charts' do
        expect(page).to have_css('#chart_comparison')
      end
    end
  end

  it 'links to the relevant advice page' do
    within('#tables') do
      within('#comparison-table') do
        expect(page).to have_link(expected_school.name, href: advice_page_path)
      end
    end
  end

  it 'displays the expected table' do
    expect(all('#comparison-table tr').map { |tr| tr.all('th,td').map(&:text) }).to eq(expected_table)
  end
end
