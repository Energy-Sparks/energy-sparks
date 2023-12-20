require 'rails_helper'

describe Audits::AuditService, type: :service do
  let(:school)            { create(:school) }
  let(:service)           { described_class.new(school) }

  describe '#recent_audit' do
    let(:created_at)       { Date.yesterday }
    let(:published)        { true }
    let!(:audit)           { create(:audit, school: school, created_at: created_at, published: published) }

    context 'a recent one' do
      it 'is returned' do
        expect(service.recent_audit).to eql audit
      end
    end

    context 'an old one' do
      let(:created_at) { Time.zone.today.last_year }

      it 'is ignored' do
        expect(service.recent_audit).to be_nil
      end
    end

    context 'an unpublished one' do
      let(:published) { false }

      it 'is ignored' do
        expect(service.recent_audit).to be_nil
      end
    end
  end

  describe '#last_audit' do
    let!(:published_audit)            { create(:audit, school: school, published: true, created_at: 3.days.ago) }
    let!(:older_published_audit)      { create(:audit, school: school, published: true, created_at: 4.days.ago) }

    it 'returns most recent audit' do
      expect(service.last_audit).to eql published_audit
    end

    context 'excluding unpuplished audits' do
      let!(:unpulished_audit) { create(:audit, school: school, published: false, created_at: 2.days.ago) }

      it 'returns published audit' do
        expect(service.last_audit).to eql published_audit
      end
    end
  end

  describe '#process' do
    let(:audit) { build(:audit, school: school) }

    it "has no observations" do
      expect(audit.observations.audit.count).to be(0)
    end

    context "calling the service" do
      before do
        service.process(audit)
      end

      it 'saves audit' do
        expect(audit).to be_persisted
      end

      it "creates observation" do
        expect(audit.observations.audit.count).to be(1)
        expect(audit.observations.audit.first.points).not_to be_nil
      end

      context "when audit isn't valid" do
        let(:audit) { build(:audit, school: nil) }

        it { expect(audit).not_to be_persisted }
      end
    end
  end
end
