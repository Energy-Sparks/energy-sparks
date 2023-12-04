# frozen_string_literal: true

require "rails_helper"

RSpec.describe TimelineComponent, type: :component, include_url_helpers: true do
  let(:observations) { [] }
  let(:all_params) { { observations: observations, classes: 'my-class', id: 'my-id' } }
  let(:params) { all_params }

  let(:html) do
    render_inline(TimelineComponent.new(**params))
  end

  context "with all params" do
    it { expect(html).to have_selector("div.timeline-component") }

    it "adds specified classes" do
      expect(html).to have_css('div.timeline-component.my-class')
    end

    it "adds specified id" do
      expect(html).to have_css('div.timeline-component#my-id')
    end
  end

  context "when observations includes an activity" do
    let(:school) { create :school }

    it "returns true" do
      true
    end
    ### one of these for each observation type
  end
end
