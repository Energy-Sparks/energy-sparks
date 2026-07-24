# frozen_string_literal: true

require 'rails_helper'

describe Holiday do
  context 'with a half term' do
    subject(:holiday) { described_class.new(:school_holiday, nil, Date.new(2026, 5, 25), Date.new(2026, 5, 29), nil) }

    it { expect(holiday.start_date).to eq(Date.new(2026, 5, 24)) }
    it { expect(holiday.end_date).to eq(Date.new(2026, 5, 30)) }
  end

  context 'with a bank holiday' do
    subject(:holiday) { described_class.new(:bank_holiday, nil, Date.new(2026, 5, 4), Date.new(2026, 5, 4), nil) }

    it { expect(holiday.start_date).to eq(Date.new(2026, 5, 4)) }
    it { expect(holiday.end_date).to eq(Date.new(2026, 5, 4)) }
  end
end
