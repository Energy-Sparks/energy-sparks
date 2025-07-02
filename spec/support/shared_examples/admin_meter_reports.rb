RSpec.shared_examples 'an admin meter report' do |help: true|
  let(:frequency) { :on_demand }
  it 'has title and description' do
    expect(page).to have_content(title)
    expect(page).to have_content(description)
  end

  it 'has metadata' do
    expect(page).to have_content(frequency.to_s.humanize)
  end

  it 'has controls' do
    expect(page).to have_button('Filter')
    expect(page).to have_link('CSV')
  end

  it 'has help', if: help do
    expect(page).to have_link('View help')
  end

  it 'has help', unless: help do
    expect(page).not_to have_link('View help')
  end

  it 'has filters' do
    expect(page).to have_field(:school_group)
    expect(page).to have_field(:user)
  end

  it 'has a table with a common set of columns' do
    headers = first('tr').all('th, td').map(&:text)[0..4]
    expect(headers).to eq(['School Group', 'Admin', 'School', 'Meter', 'Meter Name'])
  end
end
