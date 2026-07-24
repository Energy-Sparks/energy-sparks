require 'rails_helper'

describe DailyRegenerationJob do
  subject(:job) { described_class.new }

  describe '#priority' do
    it_behaves_like 'a high priority job'
  end
end
