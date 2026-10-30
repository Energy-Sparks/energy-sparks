# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SchoolStatusButtonsComponent, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(school:, current_user: create(:admin))
  end

  let(:school) { create(:school) }

  context 'when rendering' do
    subject(:html) do
      render_inline(component)
    end

    it { expect(html).to have_css('a i.fa-arrows-rotate') }
  end
end
