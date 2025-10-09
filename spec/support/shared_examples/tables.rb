RSpec.shared_examples 'it contains the expected data table' do |sortable: true, aligned: true, rows: true|
  let(:expected_rows) { nil }

  it 'has sortable columns', if: sortable do
    expect(page).to have_css("#{table_id}.table-sorted")
  end

  it 'does not have sortable columns', unless: sortable do
    expect(page).not_to have_css("#{table_id}.table-sorted")
  end

  it 'aligns the data cells correctly', if: aligned do
    body_rows = page.find("#{table_id} > tbody").find_all('tr')
    body_rows.each do |tr|
      td_cells = tr.find_all('td')[1..] || []
      td_cells.each do |td|
        expect(td[:class].to_s.split).to include('text-right')
      end
    end
  end

  it 'has the expected headers' do
    header_rows = page.find("#{table_id} > thead").all('tr')
    actual_header = header_rows.map do |tr|
      tr.find_all('th').map { |th| th.text.strip }
    end
    expect(actual_header).to eq(expected_header)
  end

  it 'has the expected rows', if: rows do
    body_rows = page.find("#{table_id} > tbody").find_all('tr')
    actual_rows = body_rows.map do |tr|
      tr.find_all('td').map { |td| td.text.strip }
    end

    expect(actual_rows).to eq(expected_rows)
  end
end
