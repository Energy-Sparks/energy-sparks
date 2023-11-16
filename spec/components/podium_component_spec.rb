# frozen_string_literal: true

require "rails_helper"

RSpec.describe PodiumComponent, type: :component, include_url_helpers: true do
  let(:scoreboard) { create :scoreboard }
  let!(:school) { create :school, scoreboard: scoreboard }
  let!(:podium) { Podium.create(school: school, scoreboard: school.scoreboard) }
  let(:all_params) { { podium: podium, classes: 'my-class', id: 'my-id' } }
  let(:params) { all_params }

  let(:html) do
    render_inline(PodiumComponent.new(**params))
  end

  context "with all params" do
    it { expect(html).to have_selector("div.podium-component") }

    it "adds specified classes" do
      expect(html).to have_css('div.podium-component.my-class')
    end

    it "adds specified id" do
      expect(html).to have_css('div.podium-component#my-id')
    end
  end

  context "when podium includes school" do
    let(:school) { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

    ## MORE TESTS HERE ##
    it { expect(html.to_s).to be_present }
  end

  context "when podium doesn't include school" do
    let(:different_scoreboard) { create(:scoreboard) }
    let(:school) { create :school, scoreboard: different_scoreboard }

    ## MORE TESTS HERE ##
    it { expect(html.to_s).to be_present }
  end

  context "with no podium" do
    let(:params) { all_params.except(:podium) }

    it "doesn't render" do
      expect(html.to_s).to be_blank
    end
  end
end
