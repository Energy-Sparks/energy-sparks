# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScoreboardSummaryComponent, type: :component, include_url_helpers: true do
  let(:activities_2023_feature) { true }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: activities_2023_feature.to_s do
      example.run
    end
  end

  let(:scoreboard) { create :scoreboard }
  let(:school) { create :school, scoreboard: scoreboard }
  let(:podium) { Podium.create(school: school, scoreboard: school.scoreboard) }

  let(:all_params) { { podium: podium } }
  let(:params) { all_params }

  subject(:component) { ScoreboardSummaryComponent.new(**params) }

  let(:html) do
    render_inline(component)
  end

  context "when there is another school on the podium" do
    let!(:other_school) { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

    it "shows scoreboard activity" do
      expect(html).to have_content("Recent activity on your scoreboard")
    end
  end

  context "when there is only 1 school on the podium" do
    it "shows energysparks activity" do
      expect(html).to have_content("Recent activity across Energy Sparks")
    end
  end

  describe "#limit" do
    it { expect(component.limit).to be(4) }
  end

  describe "#school" do
    it { expect(component.school).to eq(school) }
  end

  describe "#scoreboard" do
    it { expect(component.scoreboard).to eq(scoreboard) }
  end

  describe "#other_schools?" do
    it { expect(component.other_schools?).to be(false) }

    context "when there is another school on the podium" do
      let!(:other_school) { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

      it { expect(component.other_schools?).to be(true) }
    end
  end
end
