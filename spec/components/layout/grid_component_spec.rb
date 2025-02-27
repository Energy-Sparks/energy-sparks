# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Layout::GridComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }
  let(:cols) { 2 }
  let(:all_params) { { cols: cols, classes: classes, id: id } }

  let(:params) { all_params }

  let(:rows) { html.css('div.row') }
  let(:row) { rows.first }

  context 'with cells' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_block { 'cell 1' }
        c.with_block { 'cell 2' }
        c.with_block { 'cell 3' }
        c.with_block { 'cell 4' }
        c.with_block { 'cell 5' }
      end
    end

    it { expect(html).to have_css('div.extra-classes') }
    it { expect(html).to have_css('div#custom-id') }

    context 'with 2 cols' do
      let(:cols) { 2 }

      it { expect(rows[0]).to have_css('div.col-12.col-md-6', count: 2) }
      it { expect(rows[1]).to have_css('div.col-12.col-md-6', count: 2) }
      it { expect(rows[2]).to have_css('div.col-12.col-md-6', count: 1) }
    end

    context 'with 3 cols' do
      let(:cols) { 3 }

      it { expect(rows[0]).to have_css('div.col-12.col-md-4', count: 3) }
      it { expect(rows[1]).to have_css('div.col-12.col-md-4', count: 2) }
    end

    context 'with 4 cols' do
      let(:cols) { 4 }

      it { expect(rows[0]).to have_css('div.col-12.col-xl-3.col-sm-6', count: 4) }
      it { expect(rows[1]).to have_css('div.col-12.col-xl-3.col-sm-6', count: 1) }
    end
  end

  context 'with component classes' do
    let(:params) { all_params.merge(component_classes: 'component-classes') }

    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_block { 'cell 1' }
        c.with_block { 'cell 2' }
      end
    end

    it { expect(row).to have_css('div.component-classes', count: 2) }
  end

  context 'with inline component classes' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_block(classes: 'component-classes') { 'cell 1' }
        c.with_block { 'cell 2' }
      end
    end

    it { expect(row).to have_css('div.component-classes', count: 1) }
  end

  context 'with cell classes' do
    let(:params) { all_params.merge(cell_classes: 'cell-classes') }

    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_block { 'cell 1' }
        c.with_block { 'cell 2' }
      end
    end

    it { expect(rows[0]).to have_css('div.col-12.col-md-6.cell-classes', count: 2) }
  end

  context 'with inline cell classes' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_block(cell_classes: 'cell-classes') { 'cell 1' }
        c.with_block { 'cell 2' }
      end
    end

    it { expect(row).to have_css('div.col-12.col-md-6.cell-classes', count: 1) }
  end


  context 'with image' do
    let(:html) do
      render_inline(described_class.new(**params)) do |c|
        c.with_image src: 'laptop.jpg', classes: 'component-classes'
        c.with_block { 'cell 2' }
      end
    end

    it { expect(row).to have_xpath('.//img[contains(@src, "/assets/laptop-")]', visible: :all) }
    it { expect(row).to have_css('img.component-classes', count: 1) }
  end
end
