# frozen_string_literal: true

require "rails_helper"

RSpec.describe PodiumComponent, type: :component, include_url_helpers: true do
  let(:scoreboard) { create :scoreboard }
  let(:school) { create :school, scoreboard: scoreboard }
  let(:podium) { Podium.create(school: school, scoreboard: school.scoreboard) }
  let(:all_params) { { podium: podium, classes: 'my-class', id: 'my-id' } }
  let(:params) { all_params }

  let(:html) do
    render_inline(PodiumComponent.new(**params))
  end

  let(:activities_2023_feature) { false }

  shared_examples "a podium including school" do
    it "shows school on podium" do
      expect(html.to_s).to have_content(school.name)
    end
  end

  shared_examples "a podium not including school" do
    it "doesn't show school on podium" do
      expect(html.to_s).not_to have_content(school.name)
    end
  end

  shared_examples "a podium with placing" do |ordinal: ''|
    it { expect(html).to have_css('i.fa-crown') }

    it "shows ordinal" do
      within "p.h2" do
        expect(html.to_s).to have_content(ordinal)
      end
    end
  end

  shared_examples "a podium without placing" do |ordinal: ''|
    it { expect(html).not_to have_css('i.fa-crown') }

    it "doesn't show ordinal" do
      within "p.h2" do
        expect(html.to_s).not_to have_content(ordinal)
      end
    end
  end

  shared_examples "a podium with no points message" do
    it "displays no points text" do
      expect(html).to have_content("Your school hasn't scored any points yet this school year")
    end

    it { expect(html.to_s).to have_link("Complete an activity") }
    it { expect(html.to_s).to have_content("Complete an activity to score points on Energy Sparks.") }
  end

  shared_examples "a podium with overtake message" do |points: 50|
    it { expect(html.to_s).to have_content("You only need to score #{points} points to overtake the next school!") }
  end

  around do |example|
    ClimateControl.modify FEATURE_FLAG_ACTIVITIES_2023: activities_2023_feature.to_s do
      example.run
    end
  end

  context "with all params" do
    let(:school) { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

    it { expect(html).to have_selector("div.podium-component") }

    it "adds specified classes" do
      expect(html).to have_css('div.podium-component.my-class')
    end

    it "adds specified id" do
      expect(html).to have_css('div.podium-component#my-id')
    end
  end

  context "with activities_2023 feature flag switched on" do
    let(:activities_2023_feature) { true }

    context "when there is another school on the podium" do
      let!(:other_school) { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

      context "when school is in first place" do
        let(:school) { create :school, :with_points, score_points: 60, scoreboard: scoreboard }

        it { expect(html.to_s).to have_content("You are in 1st place on the #{scoreboard.name} scoreboard") }

        it_behaves_like "a podium including school"
        it_behaves_like "a podium with placing", ordinal: '1st'
      end

      context "when in second place" do
        let(:school) { create :school, :with_points, score_points: 30, scoreboard: scoreboard }

        it { expect(html.to_s).to have_content("You are in 2nd place on the #{scoreboard.name} scoreboard") }

        it_behaves_like "a podium including school"
        it_behaves_like "a podium with placing", ordinal: '2nd'
      end

      context "when school doesn't have any points" do
        let(:school) { create :school, scoreboard: scoreboard }

        it_behaves_like "a podium including school"
        it_behaves_like "a podium with no points message"
        it_behaves_like "a podium with overtake message", points: 50
        it_behaves_like "a podium without placing", ordinal: '2nd'
      end
    end

    context "when there isn't another school on the podium" do
      it_behaves_like "a podium not including school"
      it_behaves_like "a podium with no points message"
      it_behaves_like "a podium without placing", ordinal: '1st'
    end
  end

  context "with activities_2023 feature flag switched off" do
    let(:activities_2023_feature) { false }

    context "when there is another school on the podium" do
      let!(:other_school) { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

      context "when school is in first place" do
        let(:school) { create :school, :with_points, score_points: 60, scoreboard: scoreboard }

        it { expect(html.to_s).to have_content("Your school is in 1st place") }

        it_behaves_like "a podium including school"
        it_behaves_like "a podium with placing", ordinal: '1st'
      end

      context "when in second place" do
        let(:school) { create :school, :with_points, score_points: 30, scoreboard: scoreboard }

        it { expect(html.to_s).to have_content("Your school is in 2nd place") }

        it_behaves_like "a podium including school"
        it_behaves_like "a podium with placing", ordinal: '2nd'
      end

      context "when school doesn't have any points" do
        let(:school) { create :school, scoreboard: scoreboard }

        it_behaves_like "a podium not including school"
        it_behaves_like "a podium with no points message"
        it_behaves_like "a podium with overtake message", points: 50
        it_behaves_like "a podium without placing", ordinal: '2nd'
      end
    end

    context "when there isn't another school on the podium" do
      it_behaves_like "a podium not including school"
      it_behaves_like "a podium with no points message"
      it_behaves_like "a podium without placing", ordinal: '1st'
    end
  end

  context "with no podium" do
    let(:params) { all_params.except(:podium) }

    it "doesn't render" do
      expect(html.to_s).to be_blank
    end
  end
end
