# frozen_string_literal: true

RSpec.shared_examples 'a successful solar loader job' do
  let(:expected_subject) do
    "[energy-sparks-unknown] #{solar_feed_type} Import for #{installation_for} completed"
  end

  it 'sends email with the expected subject' do
    expect(email_subject).to eq expected_subject
  end

  it 'includes links' do
    expect(email).to have_link('View the school meters', href: meters_url)
    expect(email).to have_link('View the import logs')
  end

  it 'summarises the import' do
    expect(email).to have_text("The requested import for #{solar_feed_type} installation " \
                               "#{installation.display_name} has completed successfully")
    expect(email).to have_text('100 records were imported and 4 were updated')
  end
end

RSpec.shared_examples 'a solar loader job with loader errors' do
  let(:expected_subject) do
    "[energy-sparks-unknown] #{solar_feed_type} Import for #{installation_for} completed"
  end

  it 'sends email with the expected subject' do
    expect(email_subject).to eq expected_subject
  end

  it 'summarises the import' do
    expect(email).to have_text("The requested import for #{solar_feed_type} installation " \
                               "#{installation.display_name} has failed")
    expect(email).to have_text('The error reported was: There are errors here')
  end

  it 'includes links' do
    expect(email).to have_link('View the school meters', href: meters_url)
    expect(email).to have_link('View the import logs')
  end
end

RSpec.shared_examples 'a solar loader job that had an exception' do
  let(:expected_subject) { "[energy-sparks-unknown] #{solar_feed_type} Import for #{installation_for} failed" }

  it 'sends email with the expected subject' do
    expect(email_subject).to eq expected_subject
  end

  it 'reports the exception failure' do
    expect(email).to have_text('The requested import job has failed. An error has been logged')
    expect(email).to have_text('Its broken')
  end

  it 'includes links' do
    expect(email).to have_link('View the school meters', href: meters_url)
  end
end

shared_examples 'a solar loader job' do
  include Rails.application.routes.url_helpers
  include EmailHelpers

  subject(:job) { described_class.new }

  let(:admin) { create(:admin) }
  let(:start_date) { nil }
  let(:end_date) { nil }
  let(:email) { Capybara::Node::Simple.new(last_email.html_part.body.decoded) }
  let(:email_subject) { last_email.subject }
  let(:meters_url) do
    school_meters_url(installation.try(:meters)&.first&.school || installation.school, host: 'localhost')
  end
  let!(:upserter) do
    double = instance_double(upserter_class, perform: nil, import_log:)
    allow(upserter_class).to receive(:new).and_return(double)
    double
  end

  describe '#perform' do
    before do
      job.perform(installation:, start_date:, end_date:, notify_email: admin.email)
    end

    context 'when the load is successful' do
      let(:import_log) { create(:amr_data_feed_import_log, records_updated: 4, records_imported: 100) }

      it 'calls the upserter' do
        expect(upserter).to have_received(:perform)
      end

      context 'when sending the email' do
        it_behaves_like 'a successful solar loader job'
      end
    end

    context 'when the load is unsuccessful' do
      let(:import_log) { create(:amr_data_feed_import_log, error_messages: 'There are errors here') }

      context 'with a loading error' do
        it_behaves_like 'a solar loader job with loader errors'
      end

      context 'with an unexpected exception' do
        let(:upserter) { allow(upserter_class).to receive(:new).and_raise('Its broken') }

        it_behaves_like 'a solar loader job that had an exception'
      end
    end
  end
end
