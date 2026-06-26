# frozen_string_literal: true

require 'rails_helper'

describe SchoolDatePeriod do
  context 'when creating' do
    it 'can only be constructed with valid values' do
      expect { described_class.new(:test, '', nil, nil) }.to raise_exception(ArgumentError)
      expect { described_class.new(:test, '', Time.zone.today, nil) }.to raise_exception(ArgumentError)
      expect { described_class.new(:test, '', nil, Time.zone.today) }.to raise_exception(ArgumentError)
      expect do
        described_class.new(:test, '', Time.zone.today,
                            Time.zone.yesterday)
      end.to raise_exception(EnergySparksUnexpectedStateException)
    end
  end

  describe '#==' do
    subject(:period) { described_class.new(nil, nil, Time.zone.yesterday, Time.zone.today) }

    it { expect(period).to eq(described_class.new(nil, nil, Time.zone.yesterday, Time.zone.today)) }
    it { expect(period).not_to eq(described_class.new(:some_type, nil, Time.zone.yesterday, Time.zone.today)) }

    it { expect(period).not_to eq(described_class.new(:nil, nil, Time.zone.today.last_month, Time.zone.today)) }
    it { expect(period).not_to eq(described_class.new(:nil, nil, Time.zone.today, Time.zone.tomorrow)) }
  end

  describe '#hash' do
    subject(:period) { described_class.new(nil, nil, Time.zone.yesterday, Time.zone.today) }

    it { expect(period.hash).to eq(described_class.new(nil, nil, Time.zone.yesterday, Time.zone.today).hash) }

    it {
      expect(period.hash).not_to eq(described_class.new(:some_type, nil, Time.zone.yesterday, Time.zone.today).hash)
    }
  end
end
