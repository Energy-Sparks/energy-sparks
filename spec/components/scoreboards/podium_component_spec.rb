# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreboards::PodiumComponent, :include_url_helpers, type: :component do
  let(:scoreboard) { create :scoreboard }
  let(:school) { create :school, scoreboard: scoreboard }
  let(:podium) { Podium.create(school: school, scoreboard: school.scoreboard) }
  let(:params) { { podium: podium, classes: 'my-class', id: 'my-id' } }

  # Avoids problem with showing national placing. National Scoreboard only runs from
  # 1st Sept to 31st Jul.
  around do |example|
    travel_to Date.new(2024, 4, 1) do
      example.run
    end
  end

  before do
    create(:national_calendar, title: 'England and Wales') # required for podium to show national placing
  end

  let(:html) do
    render_inline(described_class.new(**params))
  end

  shared_examples 'a podium including school' do
    it 'shows school on podium' do
      expect(html).to have_content(school.name)
    end
  end

  shared_examples 'a podium not including school' do
    it "doesn't show school on podium" do
      expect(html).not_to have_content(school.name)
    end
  end

  shared_examples 'a podium with placing' do |ordinal: ''|
    it { expect(html).to have_css('i.fa-crown') }

    it 'shows ordinal' do
      expect(html).to have_css('p.f2', text: ordinal)
    end
  end

  shared_examples 'a podium without placing' do |ordinal: ''|
    it { expect(html).not_to have_css('i.fa-crown') }

    it "doesn't show ordinal" do
      expect(html).not_to have_css('p.f2', text: ordinal)
    end
  end

  shared_examples 'a podium with no points message' do
    it 'displays no points text' do
      expect(html).to have_content("Your school hasn't scored any points yet this school year")
    end

    it { expect(html).to have_content(I18n.t('components.podium.no_points_this_year')) }
  end

  context 'with all params' do
    let(:school) { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

    it { expect(html).to have_selector('div.scoreboards-podium-component') }

    it 'adds specified classes' do
      expect(html).to have_css('div.scoreboards-podium-component.my-class')
    end

    it 'adds specified id' do
      expect(html).to have_css('div.scoreboards-podium-component#my-id')
    end
  end

  context 'when there is another school on the podium' do
    context 'when school is in first place' do
      let(:school) { create :school, :with_points, score_points: 60, scoreboard: scoreboard }

      before { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

      it { expect(html).to have_content("You are in 1st place on the #{scoreboard.name} scoreboard") }
      it { expect(html).to have_content('and 1st place nationally') }

      it_behaves_like 'a podium including school'
      it_behaves_like 'a podium with placing', ordinal: '1st'
    end

    context 'when in second place' do
      let(:school) { create :school, :with_points, score_points: 30, scoreboard: scoreboard }

      before { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

      it { expect(html).to have_content("You are in 2nd place on the #{scoreboard.name} scoreboard") }
      it { expect(html).to have_content('and 2nd place nationally') }

      it_behaves_like 'a podium including school'
      it_behaves_like 'a podium with placing', ordinal: '2nd'
    end

    context 'when in second place nationally' do
      let(:school) { create :school, :with_points, score_points: 30, scoreboard: scoreboard }

      before { create :school, :with_points, score_points: 50, scoreboard: create(:scoreboard) }

      it { expect(html).to have_content("You are in 1st place on the #{scoreboard.name} scoreboard") }
      it { expect(html).to have_content('and 2nd place nationally') }

      it_behaves_like 'a podium including school'
      it_behaves_like 'a podium with placing', ordinal: '1st'
    end

    context "when school doesn't have any points" do
      let(:school) { create :school, scoreboard: scoreboard }

      before { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

      it_behaves_like 'a podium including school'
      it_behaves_like 'a podium with no points message'
      it_behaves_like 'a podium without placing', ordinal: '2nd'
    end
  end

  context "when there isn't another school on the podium" do
    it_behaves_like 'a podium not including school'
    it_behaves_like 'a podium with no points message'
    it_behaves_like 'a podium without placing', ordinal: '1st'
  end

  context 'with no podium' do
    let(:params) { { classes: 'my-class', id: 'my-id' } }

    it "doesn't render" do
      expect(html.to_s).to be_blank
    end
  end
end
