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

RSpec.shared_examples 'an admin meter import report' do
  it 'displays the table' do
    expect(all('tr').map { |tr| tr.all('th, td').map(&:text) }).to \
      eq([
           ['School Group', 'Admin', 'School', 'Meter', 'Meter Name',
            'Meter Type', 'Meter System', 'Data Source', 'Procurement Route', 'Meter Status', 'Manual Reads', 'Last Validated Date',
            'Issues & Notes'],
           [
             meter.school.school_group.name, 'Admin', meter.school.name, meter.mpan_mprn.to_s, meter.name,
             '', meter.t_meter_system, meter.data_source&.name, '', meter.admin_meter_status&.label, 'N', nice_dates(end_date),
             ''
           ]
         ])
  end

  it 'allows csv download' do
    click_on 'CSV'
    expect(page.response_headers['content-type']).to eq('text/csv')
    header = ['School Group', 'Admin', 'School', 'Meter', 'Meter Name',
              'Meter Type', 'Meter System', 'Data Source', 'Procurement Route', 'Meter Status', 'Manual Reads', 'Last Validated Date',
              'Issues',
              'Notes'
            ]
    expect(body).to \
      eq("#{header.join(',')}\n" \
         "#{meter.school.school_group.name},Admin,#{meter.school.name},#{meter.mpan_mprn},#{meter.name},gas,#{meter.t_meter_system},#{meter.data_source&.name},,#{meter.admin_meter_status&.label},N,#{end_date.to_date.iso8601},0,0\n")
  end
end
