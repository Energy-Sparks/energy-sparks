require 'rails_helper'

describe Targets::SchoolGroupProgressReportingService, type: :service do

  let(:enable_targets)      { false }
  let(:enough_data)         { true }
  let(:school_target)       { nil }
  let(:progress_summary)    { nil }

  let(:school_group)        { create(:school_group) }
  let!(:school)              { create(:school, school_group: school_group, enable_targets_feature: enable_targets) }

  let(:service) { Targets::SchoolGroupProgressReportingService.new(school_group) }

  before(:each) do
    allow(EnergySparks::FeatureFlags).to receive(:active?).and_return(true)
  end

  describe '#report' do

    before(:each) do
      allow_any_instance_of(Targets::SchoolTargetService).to receive(:enough_data?).and_return(enough_data)
    end

    let(:report) { service.report }

    context 'schools with target disabled' do
      it 'includes the school' do
        expect(report.size).to eql 1
        expect(report.first.school).to eq school
        expect(report.first.targets_enabled).to eq false
        expect(report.first.enough_data).to be_nil
        expect(report.first.progress_summary).to be_nil
      end
    end

    context 'schools without enough data' do
      let(:enable_targets)      { true }
      let(:enough_data)         { false }

      it 'includes the school' do
        expect(report.size).to eql 1
        expect(report.first.school).to eq school
        expect(report.first.targets_enabled).to eq true
        expect(report.first.enough_data).to eq false
      end
    end

    context 'schools with enough data but no target' do
      let(:enable_targets)      { true }
      let(:enough_data)         { true }

      it 'includes the school' do
        expect(report.size).to eql 1
        expect(report.first.school).to eq school
        expect(report.first.targets_enabled).to eq true
        expect(report.first.enough_data).to eq true
      end
    end

    context 'schools with enough data and a target' do
      let(:enable_targets)      { true }
      let(:enough_data)         { true }
      let(:school_target)       { create(:school_target, school: school) }
      let(:progress_summary)    { build(:progress_summary, school_target: school_target) }

      before(:each) do
        allow_any_instance_of(Targets::ProgressService).to receive(:progress_summary).and_return(progress_summary)
      end
      it 'includes the school' do
        expect(report.size).to eql 1
        expect(report.first.school).to eq school
        expect(report.first.targets_enabled).to eq true
        expect(report.first.enough_data).to eq true
        expect(report.first.school_target).to eql school_target
        expect(report.first.progress_summary).to eql progress_summary
      end
    end
  end
end
