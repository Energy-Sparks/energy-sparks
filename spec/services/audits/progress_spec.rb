require 'rails_helper'

describe Audits::Progress, type: :service do
  let!(:site_settings) { SiteSettings.create!(audit_activities_bonus_points: 50) }
  let!(:school) { create(:school) }

  # Audit has 3 activities of score 25 each & 3 interventions of score 30 each
  let!(:audit) { create(:audit, :with_activity_and_intervention_types, school: school, created_at: 3.days.ago) }

  subject(:service) { Audits::Progress.new(audit) }

  context 'when the audit was created less than a year ago' do
    let!(:audit) { create(:audit, :with_activity_and_intervention_types, school: school, created_at: 3.days.ago) }

    describe '#notification' do
      it { expect(service.notification).to include('recent') }
    end
  end

  context 'when the audit was created over a year ago' do
    let!(:audit) { create(:audit, :with_activity_and_intervention_types, school: school, created_at: 2.years.ago) }

    describe '#notification' do
      it { expect(service.notification).not_to include('recent') }
    end
  end

  context 'with no actions or activities completed' do
    describe '#notification' do
      it { expect(service.notification).to eq('You have completed <strong>0/3</strong> of the activities and <strong>0/3</strong> of the actions from your recent energy audit<br />Complete the others to score <strong>165</strong> points and <strong>50</strong> bonus points for completing all audit tasks') }
    end

    describe '#completed_activities_count' do
      it { expect(service.completed_activities_count).to be(0) }
    end

    describe '#total_activities_count' do
      it { expect(service.total_activities_count).to be(3) }
    end

    describe '#completed_actions_count' do
      it { expect(service.completed_actions_count).to be(0) }
    end

    describe '#total_actions_count' do
      it { expect(service.total_actions_count).to be(3) }
    end

    describe '#remaining_activities_score' do
      it { expect(service.remaining_activities_score).to be(75) }
    end

    describe '#remaining_actions_score' do
      it { expect(service.remaining_actions_score).to be(90) }
    end

    describe '#remaining_points' do
      it { expect(service.remaining_points).to be(165) }
    end

    describe '#bonus_points' do
      it { expect(service.bonus_points).to be(50) }
    end
  end

  context 'with an activity & an action completed after audit created' do
    let(:activity) { build(:activity, school: school, activity_type: audit.activity_types.first, happened_on: 1.day.ago) }
    let!(:observation) { create(:observation, school: school, observation_type: :intervention, intervention_type: audit.intervention_types.first, at: 1.day.ago) }

    before { Tasks::Recorder.new(activity, nil).process }

    describe '#notification' do
      it { expect(service.notification).to eq('You have completed <strong>1/3</strong> of the activities and <strong>1/3</strong> of the actions from your recent energy audit<br />Complete the others to score <strong>110</strong> points and <strong>50</strong> bonus points for completing all audit tasks') }
    end
  end

  context 'with an activity & an action completed before audit created' do
    let(:activity) { build(:activity, school: school, activity_type: audit.activity_types.first, happened_on: 5.days.ago) }
    let!(:observation) { create(:observation, school: school, observation_type: :intervention, intervention_type: audit.intervention_types.first, at: 5.days.ago) }

    before { Tasks::Recorder.new(activity, nil).process }

    describe '#notification' do
      it { expect(service.notification).to eq('You have completed <strong>0/3</strong> of the activities and <strong>0/3</strong> of the actions from your recent energy audit<br />Complete the others to score <strong>165</strong> points and <strong>50</strong> bonus points for completing all audit tasks') }
    end
  end

  context 'with all activies completed (with no bonus points available)' do
    before do
      audit.activity_types.each do |activity_type|
        activity = build(:activity, school: school, activity_type: activity_type, happened_on: 2.days.ago)
        Tasks::Recorder.new(activity, nil).process
      end
    end

    describe '#notification' do
      it { expect(service.notification).to eq('You have completed <strong>3/3</strong> of the activities and <strong>0/3</strong> of the actions from your recent energy audit<br />Complete the others to score <strong>90</strong> points for completing all audit tasks') }
    end
  end
end
