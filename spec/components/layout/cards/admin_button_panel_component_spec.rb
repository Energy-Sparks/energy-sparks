# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::Cards::AdminButtonPanelComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:current_user) { create(:admin) }
  let(:base_params) { { id: id, classes: classes, current_user: current_user } }

  let(:html) do
    render_inline(described_class.new(**params)) do |panel|
      panel.with_status 'Warning', style: :warning
      panel.with_button('button 1', 'link_to_button_1', style: :primary)
      panel.with_button('button 2', 'link_to_button_2', style: :secondary)
    end
  end

  describe '#render?' do
    context 'with admin' do
      it { expect(described_class.new(**base_params).render?).to be(true) }
    end

    context 'with none admin user' do
      let(:current_user) { create(:school_admin) }

      it { expect(described_class.new(**base_params).render?).to be(false) }
    end
  end

  context 'with base params' do
    let(:params) { base_params }

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it { expect(html).to have_content('Warning') }
    it { expect(html).to have_link('button 1', href: 'link_to_button_1') }
    it { expect(html).to have_link('button 2', href: 'link_to_button_2') }
  end
end
