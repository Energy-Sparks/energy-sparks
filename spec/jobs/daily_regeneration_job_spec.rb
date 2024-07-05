require 'rails_helper'

describe DailyRegenerationJob do
  subject(:job) { described_class.new }

  describe '#priority' do
    it_behaves_like 'a high priority job'

    it 'is higher priority than sending weekly alert emails' do
      expect(job.priority).to be < GenerateSubscriptionsJob.new.priority
    end
  end
end
