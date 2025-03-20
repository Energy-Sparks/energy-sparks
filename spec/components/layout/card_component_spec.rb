# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::CardComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:theme) { :dark }

  let(:all_params) { { classes: classes, id: id, theme: theme } }

  let(:params) { all_params }

  context 'with feature card' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_feature_card(theme: :dark) do |feature|
          feature.with_description { 'hello' }
        end
      end
    end

    it do
      expect(html).to have_content('hello')
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it_behaves_like 'a layout component' do
      let(:expected_theme) { theme }
    end
  end
end
