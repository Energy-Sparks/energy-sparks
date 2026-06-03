# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scoreboards::SummaryComponent, :include_url_helpers, type: :component do
  let(:scoreboard) { create :scoreboard }
  let(:school) { create :school, scoreboard: scoreboard }
  let(:podium) { Podium.create(school: school, scoreboard: school.scoreboard) }

  let(:params) { { podium: podium, user: create(:school_admin, school: school) } }

  subject(:component) { described_class.new(**params) }

  let(:html) do
    render_inline(component)
  end

  describe '#limit' do
    it { expect(component.limit).to be(4) }
  end

  describe '#school' do
    it { expect(component.featured_school).to eq(school) }
  end

  describe '#scoreboard' do
    it { expect(component.scoreboard).to eq(scoreboard) }
  end

  describe '#other_schools?' do
    it { expect(component.other_schools?).to be(false) }

    context 'when there is another school on the podium' do
      before { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

      it { expect(component.other_schools?).to be(true) }
    end
  end

  describe '#observations' do
    context 'with points' do
      before { create :school, :with_points, score_points: 50, scoreboard: scoreboard }

      it { expect(component.observations).not_to be_empty }
    end

    context 'with no points' do
      before { create :school, :with_points, score_points: 0, scoreboard: scoreboard }

      it { expect(component.observations).to be_empty }
    end
  end
end
