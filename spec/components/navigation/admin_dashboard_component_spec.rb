# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Navigation::AdminDashboardComponent, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:current_user) { create(:admin) }

  let(:params) do
    { current_user: }
  end

  context 'when rendering' do
    let(:html) do
      render_inline(component)
    end

    it { expect(html).to have_link('Dashboard Home', href: admin_dashboard_path(current_user)) }

    describe 'manage schools section' do
      it 'has the title section' do
        expect(html).to have_content('Manage Schools')
      end

      it 'has the correct links' do
        expect(html).to have_link('School Groups',
                                  href: admin_dashboard_school_groups_path(current_user))
      end
    end
  end
end
