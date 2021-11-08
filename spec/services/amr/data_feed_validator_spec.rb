require 'rails_helper'

describe Amr::DataFeedValidator do

  let(:header)       { 'MPAN,MSN,DAY,00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30' }

  let(:header_row)   { header.split(",") }

  let(:orsis_config) { build(:amr_data_feed_config,
      description: 'Orsis',
      identifier: 'orsis',
      date_format: "%d/%m/%Y",
      mpan_mprn_field: 'MPAN',
      reading_date_field: 'DAY',
      reading_fields:   '00:00,00:30,01:00,01:30,02:00,02:30,03:00,03:30,04:00,04:30,05:00,05:30,06:00,06:30,07:00,07:30,08:00,08:30,09:00,09:30,10:00,10:30,11:00,11:30,12:00,12:30,13:00,13:30,14:00,14:30,15:00,15:30,16:00,16:30,17:00,17:30,18:00,18:30,19:00,19:30,20:00,20:30,21:00,21:30,22:00,22:30,23:00,23:30'.split(','),
      header_example: header,
      number_of_header_rows: 0,
    )
  }

  before do
    @readings = [
      ["2199989616188","row with 6 empty readings at end","01/11/2020","9.651","9.224","9.152","9.082","9.122","9.114","9.295","9.377","9.025","9.158","9.598","10.15","11.773","21.158","26.785","30.936","37.018","46.971","57.39","53.254","54.996","56.145","54.688","55.224","52.758","45.837","43.014","45.979","44.66","49.465","47.153","47.905","44.714","41.348","41.487","38.259","32.051","32.051","32.051","32.051","32.051","32.051","","","","","",""],
      ["2199989616188","full row","02/11/2020","9.651","9.224","9.152","9.082","9.122","9.114","9.295","9.377","9.025","9.158","9.598","10.15","11.773","21.158","26.785","30.936","37.018","46.971","57.39","53.254","54.996","56.145","54.688","55.224","52.758","45.837","43.014","45.979","44.66","49.465","47.153","47.905","44.714","41.348","41.487","38.259","32.051","32.051","32.051","32.051","32.051","32.051","32.051","32.051","32.051","32.051","32.051","32.051"],
      ["2199989616188","row with 4 nil readings at start","03/11/2020",nil,nil,nil,nil,"9.377","9.377","9.377","9.377","9.025","9.158","9.598","10.15","11.773","21.158","26.785","30.936","37.018","46.971","57.39","53.254","54.996","56.145","54.688","55.224","52.758","45.837","43.014","45.979","44.66","49.465","47.153","47.905","44.714","41.348","41.487","38.259","32.051","32.051","32.051","32.051","32.051","32.051","32.051","32.051","32.051","32.051","32.051","32.051"],
    ]
  end

  it 'ignores filter if no limit set' do
    results = Amr::DataFeedValidator.new(orsis_config, @readings).perform

    expect(results.size).to eq(3)
    expect(results).to eq(@readings)
  end

  context 'with empty files' do

    it 'handles empty files when header matches config' do
      only_header = [header_row]
      results = Amr::DataFeedValidator.new(orsis_config, only_header).perform
      expect(results).to be_empty
    end

    it 'handles empty files when configuration says to skip rows' do
      orsis_config.header_example = nil
      orsis_config.number_of_header_rows = 1
      only_header = [["to", "be", "skipped"]]
      results = Amr::DataFeedValidator.new(orsis_config, only_header).perform
      expect(results).to be_empty
    end

    it 'handles empty files when header row configured but it doesnt match what is provided' do
      orsis_config.number_of_header_rows = 1
      only_header = [["sep="]]
      results = Amr::DataFeedValidator.new(orsis_config, only_header).perform
      expect(results).to be_empty
    end

    #this caused a problem in live, a data file was set for a config that had multiple
    #header rows, but the file had a smaller header and no data
    it 'raises exception when configuration expects more header rows than is in data' do
      orsis_config.number_of_header_rows = 2
      only_header = [["sep="]]
      expect { Amr::DataFeedValidator.new(orsis_config, only_header).perform }.to raise_error Amr::DataFeedValidatorException
    end

  end

  it 'removes partial rows if limit set' do
    orsis_config.missing_readings_limit = 5

    results = Amr::DataFeedValidator.new(orsis_config, @readings).perform

    expect(results.size).to eq(2)
    expect(results.first).to eq(@readings.second)
    expect(results.last).to eq(@readings.third)
  end

  it 'removes all partial rows' do
    orsis_config.missing_readings_limit = 0

    results = Amr::DataFeedValidator.new(orsis_config, @readings).perform

    expect(results.size).to eq(1)
    expect(results).to eq([@readings.second])
  end

  it 'removes broken rows' do
    orsis_config.missing_readings_limit = 2

    @readings << ["2199989616188","broken row","03/11/2020",""]

    results = Amr::DataFeedValidator.new(orsis_config, @readings).perform

    expect(results.size).to eq(1)
    expect(results).to eq([@readings.second])
  end
end
