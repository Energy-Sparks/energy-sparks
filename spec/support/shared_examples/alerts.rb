# frozen_string_literal: true

RSpec.shared_examples 'a valid alert' do |date:|
  it { expect(alert.valid_alert?).to be true }
  it { expect(alert.enough_data).to eq(:enough) }
  it { expect(alert.analysis_date).to eq(date) }
end

RSpec.shared_examples 'an invalid alert' do |date:|
  it { expect(alert.valid_alert?).to be false }
  it { expect(alert.enough_data).to eq(:not_enough) }
  it { expect(alert.analysis_date).to eq(date) }
end

RSpec.shared_examples 'a never relevant alert' do |fuel_type, asof_date: Date.new(2023, 12, 23)|
  context "when a school has #{fuel_type} only" do
    include_context 'with an aggregated meter with tariffs and school times' do
      let(:fuel_type) { fuel_type }
    end
    include_context 'with today' do
      let(:asof_date) { asof_date }
    end

    it { expect(alert.relevance).to eq(:never_relevant) }
  end
end
