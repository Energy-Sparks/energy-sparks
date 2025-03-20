# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::CardComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:theme) { :dark }

  let(:all_params) { { classes: classes, id: id, theme: theme } }

  let(:params) { all_params }

  context 'with base params' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_body { 'hello' }
      end
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it_behaves_like 'a layout component' do
      let(:expected_theme) { theme }
    end
  end

  context 'with image' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_image(src: 'laptop.jpg')
      end
    end

    it { expect(html).to have_selector('img.card-img-top') }
    it { expect(html).to have_xpath('.//img[contains(@src, "/assets/laptop-")]', visible: :all) }
  end

  context 'with body' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_body { 'body' }
      end
    end

    it { expect(html).to have_content('body') }
    it { expect(html).to have_selector('.card-body') }
  end

  context 'with list_group' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_list_group { 'list group' }
      end
    end

    it { expect(html).to have_selector('.list-group.list-group-flush') }
  end

  context 'with feature card' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_feature_card(theme: :dark) do |feature|
          feature.with_description { 'description' }
        end
      end
    end

    it { expect(html).to have_content('description') }
  end

  context 'with footer' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_footer { 'footer' }
      end
    end

    it { expect(html).to have_content('footer') }
    it { expect(html).to have_selector('.card-footer') }
  end
end
