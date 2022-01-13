require 'rails_helper'

describe Audits::AuditService do

  let(:school)            { create(:school) }
  let(:service)           { described_class.new(school) }

  describe '#recent_audit' do
    let(:created_at)       { Date.yesterday }
    let!(:audit)           { create(:audit, school: school, created_at: created_at) }

    context 'a recent one' do
      it 'is returned' do
        expect(service.recent_audit).to eql audit
      end
    end

    context 'an old one' do
      let(:created_at)      { Date.today.last_year }

      it 'is ignored' do
        expect(service.recent_audit).to be_nil
      end
    end
  end

  describe '#process' do
    let(:audit)           { build(:audit, school: school) }

    it 'saves audit' do
      service.process(audit)
      expect(audit).to be_persisted
    end

    it 'only create observation if valid' do
      audit.school = nil
      service.process(audit)
      expect(audit).to_not be_persisted
    end

    it 'creates observation when saving audit' do
      expect { service.process(audit) }.to change(Observation, :count).from(0).to(1)
      expect(Observation.first.audit).to eql audit
      expect(Observation.first.points).to_not be_nil
      expect(Observation.first.audit?).to be true
    end

  end


end
