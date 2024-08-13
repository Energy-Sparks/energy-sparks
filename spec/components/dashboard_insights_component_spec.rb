# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardInsightsComponent, type: :component, include_url_helpers: true do
  let(:school) { create(:school) }
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:alerts) { [] }
  let(:progress_summary) { nil }

  let(:params) do
    {
      school: school,
      id: id,
      classes: classes,
      alerts: alerts,
      progress_summary: progress_summary
    }
  end

  let(:html) { render_inline(described_class.new(**params)) }

  it_behaves_like 'an application component' do
    let(:expected_classes) { classes }
    let(:expected_id) { id }
  end
end
