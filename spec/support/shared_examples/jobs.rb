# frozen_string_literal: true

RSpec.shared_examples 'a high priority job' do
  it 'has a high priority' do
    expect(job.priority).to eq(5)
  end

  it 'is higher priority than sending weekly alert emails' do
    expect(job.priority).to be < GenerateSubscriptionsJob.new.priority
  end
end

RSpec.shared_examples 'a low priority job' do
  it 'has a low priority' do
    expect(job.priority).to eq(10)
  end
end
