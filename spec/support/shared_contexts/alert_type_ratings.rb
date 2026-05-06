# frozen_string_literal: true

RSpec.shared_context 'with alert type ratings' do
  let!(:alert_type_rating_low) do
    create(:alert_type_rating,
           alert_type:,
           rating_from: 0,
           rating_to: 4,
           management_priorities_active: true,
           description: 'low')
  end
  let!(:alert_type_rating_medium) do
    create(:alert_type_rating,
           alert_type:,
           rating_from: 4.1,
           rating_to: 6,
           management_priorities_active: true,
           description: 'medium')
  end
  let!(:alert_type_rating_high) do
    create(:alert_type_rating,
           alert_type:,
           rating_from: 6.1,
           rating_to: 10,
           management_priorities_active: true,
           description: 'high')
  end

  before do
    create(
      :alert_type_rating_content_version,
      alert_type_rating: alert_type_rating_low,
      management_priorities_title: 'Spending too much money on heating (low)'
    )
    create(
      :alert_type_rating_content_version,
      alert_type_rating: alert_type_rating_medium,
      management_priorities_title: 'Spending too much money on heating (medium)'
    )
    create(
      :alert_type_rating_content_version,
      alert_type_rating: alert_type_rating_high,
      management_priorities_title: 'Spending too much money on heating (high)'
    )
    alerts if defined? alerts
    # just run the services to set up rest of test data
    schools.each { |school| Alerts::GenerateContent.new(school).perform }
  end
end
