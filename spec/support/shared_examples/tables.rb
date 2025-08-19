RSpec.shared_examples 'it contains the expected data table' do |sortable: true, aligned: true, rows: true|
  let(:expected_rows) { nil }

  it 'has sortable columns', if: sortable do
    expect(page).to have_css("#{table_id}.table-sorted")
  end

  it 'aligns the data cells correctly', if: aligned do
    all("#{table_id} > tbody > tr").each do |tr|
      tr.all('td')[1..].each do |td|
        expect(td[:class].to_s.split).to include('text-right')
      end
    end
  end

  it 'has the expected headers' do
    expect(all("#{table_id} > thead > tr").map { |tr| tr.all('th').map(&:text) }).to \
      eq(expected_header)
  end

  it 'has the expected rows', if: rows do
    expect(all("#{table_id} > tbody > tr").map { |tr| tr.all('td').map(&:text) }).to \
      eq(expected_rows)
  end
end
