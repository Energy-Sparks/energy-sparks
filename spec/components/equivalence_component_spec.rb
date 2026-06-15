# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EquivalenceComponent, type: :component do
  subject(:component) { described_class.new(**params) }

  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:image_name) { 'television' }
  let(:show_fuel_type) { false }
  let(:params) do
    {
      id: id,
      image_name: image_name,
      classes: classes,
      fuel_type: :electricity,
      show_fuel_type: show_fuel_type
    }
  end

  describe '#show_image?' do
    it { expect(component.show_image?).to be true }

    context 'with no image' do
      let(:image_name) { 'no_image' }

      it { expect(component.show_image?).to be false }
    end
  end

  describe '#show_fuel_type?' do
    it { expect(component.show_fuel_type?).to be false}

    context 'with flag' do
      let(:show_fuel_type) { true }

      it { expect(component.show_fuel_type?).to be true}

      context 'when param is missing' do
        let(:params) do
          {
            image_name: image_name,
            show_fuel_type: show_fuel_type
          }
        end

        it { expect(component.show_fuel_type?).to be false }
      end
    end
  end

  context 'when rendering' do
    let(:content) { '<p>Content</p>' }

    context 'with header' do
      let(:header) { '<div>text</div><h1>Header</h1>' }

      let(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_header { header }
          content
        end
      end

      it { expect(html).to have_css('div.equivalence-component.horizontal') }
      it { expect(html).to have_content('Header') }
      it { expect(html).to have_content(content) }

      it_behaves_like 'an application component' do
        let(:expected_classes) { classes }
        let(:expected_id) { id }
      end
    end

    context 'with title and equivalence' do
      let(:header) { '<div>text</div><h1>Header</h1>' }

      let(:html) do
        render_inline(described_class.new(**params)) do |c|
          c.with_title { 'Title' }
          c.with_equivalence { 'Equivalence' }
          content
        end
      end

      it { expect(html).to have_content('Title') }
      it { expect(html).to have_content('Equivalence') }

      it { expect(html).to have_css('div.equivalence-component.horizontal') }
      it { expect(html).to have_content(content) }

      it_behaves_like 'an application component' do
        let(:expected_classes) { classes }
        let(:expected_id) { id }
      end
    end

    context 'with fuel_type' do
      let(:html) do
        render_inline(described_class.new(**params))
      end

      let(:show_fuel_type) { true }

      it { expect(html).not_to have_content(I18n.t('common.electricity')) }

      context 'with vertical layout' do
        let(:params) do
          {
            image_name: image_name,
            fuel_type: :electricity,
            show_fuel_type: show_fuel_type,
            layout: :vertical
          }
        end

        it { expect(html).to have_css('div.equivalence-component.vertical') }
        it { expect(html).to have_content(I18n.t('common.electricity')) }
      end
    end
  end
end
