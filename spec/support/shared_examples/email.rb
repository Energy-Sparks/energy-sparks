# frozen_string_literal: true

RSpec.shared_examples 'it has a csv attachment' do
  let(:attachment) { email.attachments.first }
  it 'has exactly one attachment' do
    expect(email.attachments.count).to eq(1)
  end

  it 'has the correct content type' do
    expect(attachment.content_type).to eq('text/csv; charset=UTF-8')
  end

  it 'has the correct filename' do
    expect(attachment.filename).to eq(filename)
  end

  it 'has the correct csv data' do
    expect(attachment.body.raw_source.split("\n")).to eq(data)
  end
end
