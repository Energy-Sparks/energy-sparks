require 'rails_helper'

describe Audits::Progress do
  let!(:site_settings) { SiteSettings.create!(audit_activities_bonus_points: 50) }
  let!(:school) { create(:school) }

  # Audit has 3 activities of score 25 each & 3 interventions of score 30 each
  let!(:audit) { create(:audit, :with_activity_and_intervention_types, school: school) }

  subject(:service) { Audits::Progress.new(audit) }

  # doesn't include activities or interventions completed before the audit?
  # still to test with actions / activities completed
  describe "#notification_text" do
    it { expect(service.notification_text).to eq("You have completed <strong>0/3</strong> of the activities and <strong>0/3</strong> of the actions from your recent energy audit. Complete the others to score <span class=\"badge badge-success\">165</span> points and <span class=\"badge badge-success\">50</span> bonus points for completing all audit tasks") }
  end

  describe "#completed_activities_count" do
    it { expect(service.completed_activities_count).to be(0) }
  end

  describe "#total_activities_count" do
    it { expect(service.total_activities_count).to be(3) }
  end

  describe "#completed_actions_count" do
    it { expect(service.completed_actions_count).to be(0) }
  end

  describe "#total_actions_count" do
    it { expect(service.total_actions_count).to be(3) }
  end

  describe "#remaining_activities_score" do
    it { expect(service.remaining_activities_score).to be(75) }
  end

  describe "#remaining_actions_score" do
    it { expect(service.remaining_actions_score).to be(90) }
  end

  describe "#remaining_points" do
    it { expect(service.remaining_points).to be(165) }
  end

  describe "#bonus_points" do
    it { expect(service.bonus_points).to be(50) }
  end
end
