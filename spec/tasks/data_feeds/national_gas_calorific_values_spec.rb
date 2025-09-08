# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'data_feeds:national_gas_calorific_values' do # rubocop:disable RSpec/DescribeClass
  before { Rails.application.load_tasks unless Rake::Task.tasks.any? }

  let(:task) do
    task = Rake::Task[self.class.description]
    task.reenable
    task
  end

  it 'loads readings' do
    travel_to(Date.new(2025, 3, 9))
    zone = create(:local_distribution_zone)
    stub_request(:get, 'https://data.nationalgas.com/api/find-gas-data-download?applicableFor=Y' \
                       "&dateFrom=2023-03-09&dateTo=2025-03-09&dateType=GASDAY&ids=#{zone.publication_id}" \
                       '&latestFlag=Y&type=CSV')
      .to_return(body: CSV.generate { |csv| csv << %w[applicable_for value] << ['2024-04-10', '1.0'] })
    task.invoke
    expect(zone.readings).to contain_exactly(have_attributes(date: Date.new(2024, 4, 10), calorific_value: 1.0))
    stub_request(:get, 'https://data.nationalgas.com/api/find-gas-data-download?applicableFor=Y' \
                       "&dateFrom=2024-04-11&dateTo=2025-03-09&dateType=GASDAY&ids=#{zone.publication_id}" \
                       '&latestFlag=Y&type=CSV')
      .to_return(body: '')
    task.reenable
    task.invoke
  end
end
