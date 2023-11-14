RSpec.shared_examples "a successful solar loader job" do |solar_feed_type:|
  let(:expected_subject) { "[energy-sparks-unknown] #{solar_feed_type} Import for #{installation.school.name} Completed" }

  it 'sends email with the expected subject' do
    expect(email_subject).to eq expected_subject
  end

  it 'includes links' do
    expect(html_email).to have_link("View the school meters", href: meters_url)
    expect(html_email).to have_link("View the import logs")
  end

  it 'summarises the import' do
    expect(html_email).to have_text("The requested import for #{solar_feed_type} installation #{installation.site_id} has completed successfully")
    expect(html_email).to have_text("100 records were imported and 4 were updated")
  end
end

RSpec.shared_examples "a solar loader job with loader errors" do |solar_feed_type:|
  let(:expected_subject) { "[energy-sparks-unknown] #{solar_feed_type} Import for #{installation.school.name} Completed" }

  it 'sends email with the expected subject' do
    expect(email_subject).to eq expected_subject
  end

  it 'summarises the import' do
    expect(html_email).to have_text("The requested import for #{solar_feed_type} installation #{installation.site_id} has failed")
    expect(html_email).to have_text("The error reported was: There are errors here")
  end

  it 'includes links' do
    expect(html_email).to have_link("View the school meters", href: meters_url)
    expect(html_email).to have_link("View the import logs")
  end
end

RSpec.shared_examples "a solar loader job that had an exception" do |solar_feed_type:|
  let(:expected_subject) { "[energy-sparks-unknown] #{solar_feed_type} Import for #{installation.school.name} Failed" }

  it 'sends email with the expected subject' do
    expect(email_subject).to eq expected_subject
  end

  it 'reports the exception failure' do
    expect(html_email).to have_text("The requested import job has failed. An error has been logged")
    expect(html_email).to have_text("Its broken")
  end

  it 'includes links' do
    expect(html_email).to have_link("View the school meters", href: meters_url)
  end
end
