# frozen_string_literal: true

RSpec.shared_examples 'a temporal ranged model' do
  let(:today) { Time.zone.today }

  let!(:expired_record) do
    create(described_class.model_name.singular,
           start_date: today - 10.days,
           end_date: today - 1.day)
  end

  let!(:current_record) do
    create(described_class.model_name.singular,
           start_date: today - 5.days,
           end_date: today + 5.days)
  end

  let!(:future_record) do
    create(described_class.model_name.singular,
           start_date: today + 1.day,
           end_date: today + 10.days)
  end

  describe 'scopes' do
    it 'returns expired records' do
      expect(described_class.expired(today)).to contain_exactly(expired_record)
    end

    it 'returns current records' do
      expect(described_class.current(today)).to contain_exactly(current_record)
    end

    it 'returns future records' do
      expect(described_class.future(today)).to contain_exactly(future_record)
    end
  end

  describe 'instance methods' do
    it '#expired?' do
      expect(expired_record.expired?(today)).to be true
      expect(current_record.expired?(today)).to be false
      expect(future_record.expired?(today)).to be false
    end

    it '#current?' do
      expect(current_record.current?(today)).to be true
      expect(expired_record.current?(today)).to be false
      expect(future_record.current?(today)).to be false
    end

    it '#future?' do
      expect(future_record.future?(today)).to be true
      expect(current_record.future?(today)).to be false
      expect(expired_record.future?(today)).to be false
    end
  end
end
