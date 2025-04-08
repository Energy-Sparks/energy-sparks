RSpec.shared_examples 'a form with a customised trix component' do |controls: :default, charts: false|
  let(:id) { nil }

  let(:selector) do
    id ? "##{id}.forms-trix-component" : '.forms-trix-component'
  end

  let(:size) { :default }
  let(:button_size) { :default }

  it do
    within(selector) do
      expect(page).to have_css('trix-editor')
    end
  end

  it 'has expected size' do
    expect(page).to have_css("#{selector}.#{size}")
  end

  it 'has expected button size' do
    expect(page).to have_css("#{selector}.buttons-#{button_size}")
  end

  it 'has simplified controls', if: controls == :simple do
    expect(page).to have_css("#{selector}.controls-#{controls}")
    within(selector) do
      expect(page).not_to have_css('button[data-trix-attribute="quote"]')
      expect(page).not_to have_css('button[data-trix-attribute="code"]')
      expect(page).not_to have_css('button[data-trix-attribute="chart"]')
      expect(page).not_to have_css('button[data-trix-action="x-heading"]')
      expect(page).not_to have_css('button[data-trix-action="youtube"]')
    end
  end

  it 'has advanced controls', if: controls == :advanced do
    expect(page).to have_css("#{selector}.controls-#{controls}")
    within(selector) do
      expect(page).to have_css('button[data-trix-attribute="quote"]')
      expect(page).to have_css('button[data-trix-attribute="code"]')
      expect(page).to have_css('button[data-trix-action="x-heading"]')
      expect(page).to have_css('button[data-trix-action="youtube"]')
    end
  end

  it 'does not have chart button', unless: charts do
    within(selector) do
      expect(page).not_to have_css('button[data-trix-action="chart"]')
    end
  end

  it 'has a chart button', if: charts do
    within(selector) do
      expect(page).to have_css('button[data-trix-action="chart"]')
    end
  end
end

RSpec.shared_examples 'a trix component with a working chart button' do
  let(:id) { nil }

  let(:selector) do
    id ? "##{id}.forms-trix-component" : '.forms-trix-component'
  end

  it 'embeds a chart when clicked' do
    within(selector) do
      find('button[data-trix-action="chart"]').click
      select chart_id, from: 'chart-list-chart'
      click_on 'Insert'
      expect(find('trix-editor')).to have_text('{{#chart}}last_7_days_intraday_gas{{/chart}}')
    end
  end
end

RSpec.shared_examples 'a trix component with a working heading button' do
  let(:content) { 'Content' }
  let(:id) { nil }

  let(:selector) do
    id ? "##{id}.forms-trix-component" : '.forms-trix-component'
  end

  it 'inserts the correct heading' do
    within(selector) do
      fill_in_trix with: content
      find('button[data-trix-action="x-heading"]').click
      find('button[data-trix-attribute="heading2"]').click
      expect(find('trix-editor').value).to eq("<h2>#{content}</h2>")
    end
  end
end

RSpec.shared_examples 'a trix component with a working youtube embed button' do
  let(:id) { nil }

  let(:selector) do
    id ? "##{id}.forms-trix-component" : '.forms-trix-component'
  end

  it 'inserts a youtube embed' do
    within(selector) do
      find('button[data-trix-action="youtube"]').click
      fill_in 'youtube-url', with: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
      click_on 'Insert'
      # find the thumbnail image, will retry allowing the ajax call to complete
      expect(find('img[src="http://i3.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg"]')).not_to be_nil
    end
  end
end
