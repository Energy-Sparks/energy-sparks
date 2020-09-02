require 'energy_sparks/csv_loader'


describe EnergySparks::CsvLoader do

  it 'converts headers to symbols' do
    csv = <<~CSV
      Header 1, Header 2
      1, 2
    CSV
    results = EnergySparks::CsvLoader.from_text(csv)
    expect(results.first.headers).to eq([:header_1, :header_2])
  end

  it 'removes lines with no values' do
    csv = <<~CSV
      Header 1, Header 2
      ,
      1, 2
    CSV
    results = EnergySparks::CsvLoader.from_text(csv)
    expect(results.size).to eq(1)
  end

  it 'removes empty lines' do
    csv = <<~CSV
      Header 1, Header 2
      1, 2

    CSV
    results = EnergySparks::CsvLoader.from_text(csv)
    expect(results.size).to eq(1)
  end

  it 'strips whitespace from around values' do
    csv = <<~CSV
      Header 1, Header 2
       1, 2
    CSV
    results = EnergySparks::CsvLoader.from_text(csv)
    expect(results.first.fields).to eq(["1", "2"])
  end
end
