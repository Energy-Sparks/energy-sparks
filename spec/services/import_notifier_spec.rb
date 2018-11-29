require 'rails_helper'

describe ImportNotifier do

  let(:sheffield_config) { create(:amr_data_feed_config, description: 'Sheffield') }
  let(:bath_config) { create(:amr_data_feed_config, description: 'Bath') }


  it 'sends an email with the import count for each logged import with its config details' do
    create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
    create(:amr_data_feed_import_log, amr_data_feed_config: bath_config, records_imported: 1, import_time: 1.day.ago)

    ImportNotifier.new.notify(from: 2.days.ago, to: Time.now)

    email = ActionMailer::Base.deliveries.last

    expect(email.subject).to eq('[energy-sparks] Energy Sparks import: 2 imports processed')
    expect(email.html_part.body.to_s).to include('Sheffield: imported 200 new readings')
    expect(email.html_part.body.to_s).to include('Bath: imported 1 new reading')
  end

  it 'filters on time' do
    create(:amr_data_feed_import_log, amr_data_feed_config: sheffield_config, records_imported: 200, import_time: 1.day.ago)
    create(:amr_data_feed_import_log, amr_data_feed_config: bath_config, records_imported: 1, import_time: 1.week.ago)

    ImportNotifier.new.notify(from: 2.days.ago, to: Time.now)

    email = ActionMailer::Base.deliveries.last
    expect(email.subject).to eq('[energy-sparks] Energy Sparks import: 1 import processed')
    expect(email.html_part.body.to_s).to_not include('Bath')
  end

  it 'handles no logs' do
    ImportNotifier.new.notify(from: 2.days.ago, to: Time.now)
    email = ActionMailer::Base.deliveries.last
    expect(email.subject).to eq('[energy-sparks] Energy Sparks import: 0 imports processed')
  end

  it 'can override the emails subject' do
    ImportNotifier.new(description: 'early morning import').notify(from: 2.days.ago, to: Time.now)
    email = ActionMailer::Base.deliveries.last
    expect(email.subject).to eq('[energy-sparks] Energy Sparks early morning import: 0 imports processed')
  end
end
