# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TimelineComponent, type: :component, include_url_helpers: true do
  let(:observation) { create(:observation, :activity) }
  let(:observations) { [observation] }
  let(:show_actions) { true }
  let(:all_params) { { observations: observations, classes: 'my-class', id: 'my-id', show_actions: show_actions } }
  let(:params) { all_params }
  let(:current_user) { create(:admin) }

  before do
    # This allows us to set what the current user is during rendering
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
  end

  let(:html) do
    with_controller_class ApplicationController do
      render_inline(TimelineComponent.new(**params))
    end
  end

  context 'with all params' do
    it { expect(html).to have_selector('div.timeline-component') }

    it 'adds specified classes' do
      expect(html).to have_css('div.timeline-component.my-class')
    end

    it 'adds specified id' do
      expect(html).to have_css('div.timeline-component#my-id')
    end
  end
end
