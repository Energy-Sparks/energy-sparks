# frozen_string_literal: true

RSpec.shared_examples 'a date ranged model' do
  context 'when end_date is before start_date' do
    subject do
      build(
        described_class.model_name.singular,
        start_date: Time.zone.today,
        end_date:   Date.yesterday
      )
    end

    it 'is invalid' do
      expect(subject).not_to be_valid
      expect(subject.errors[:end_date]).to include('must be on or after the start date')
    end
  end

  context 'when end_date equals start_date' do
    subject do
      build(
        described_class.model_name.singular,
        start_date: Time.zone.today,
        end_date:   Time.zone.today
      )
    end

    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  context 'when end_date is after start_date' do
    subject do
      build(
        described_class.model_name.singular,
        start_date: Time.zone.today,
        end_date:   Date.tomorrow
      )
    end

    it 'is valid' do
      expect(subject).to be_valid
    end
  end
end
