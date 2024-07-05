RSpec.shared_examples 'a high priority job' do
  it 'has a high priority' do
    expect(job.priority).to eq(5)
  end
end

RSpec.shared_examples 'a low priority job' do
  it 'has a low priority' do
    expect(job.priority).to eq(10)
  end
end
