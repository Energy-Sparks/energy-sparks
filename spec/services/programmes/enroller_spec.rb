require 'rails_helper'

describe Programmes::Enroller do
  let(:school)          { create(:school) }
  let(:programme_type)  { create(:programme_type) }
  let(:enrol_programme) { nil }

  let(:service) { Programmes::Enroller.new(enrol_programme) }

  before do
    allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
  end

  describe '#enrol' do
    context 'when there is no default programme type' do
      before do
        service.enrol(school)
      end

      it 'does nothing' do
        expect(school.programmes.any?).to be false
      end
    end

    context 'when there is a default programme type' do
      let!(:programme_type)  { create(:programme_type, default: true) }

      before do
        service.enrol(school)
      end

      it 'enrolls the school' do
        expect(school.programmes.any?).to be true
        expect(school.programmes.first.programme_type).to eql programme_type
      end
    end

    context 'when the school is already enrolled' do
      let!(:programme_type)  { create(:programme_type, default: true) }

      before do
        service.enrol(school)
      end

      it 'doesnt enrol again' do
        expect(school.programmes.count).to be 1
        service.enrol(school)
        expect(school.programmes.count).to be 1
      end
    end

    context 'when a programme type is supplied' do
      let!(:other_programme_type)  { create(:programme_type, default: true) }
      let(:enrol_programme) { programme_type }

      before do
        service.enrol(school)
      end

      it 'uses the right programme' do
        expect(school.programmes.first.programme_type).to eql programme_type
      end
    end
  end

  describe '#enroll_all' do
    let!(:school) { create(:school) }
    let!(:enrol_programme) { programme_type }
    let!(:programme_type)  { create(:programme_type, default: true) }

    before do
      service.enrol_all
    end

    it 'enrolls them' do
      school.reload
      expect(school.programmes.first.programme_type).to eql programme_type
    end
  end
end
