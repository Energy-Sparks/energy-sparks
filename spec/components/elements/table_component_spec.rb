require 'rails_helper'

RSpec.describe Elements::TableComponent, :include_application_helper, type: :component do
  let(:id) { 'custom-table' }
  let(:classes) { 'table table-striped' }
  let(:params) { { id: id, classes: classes } }

  describe 'a table with header, body, and footer' do
    let(:html) do
      render_inline(described_class.new(**params)) do |component|
        component.with_head_row do |row|
          row.with_header_cell('Head Cell A')
          row.with_header_cell('Head Cell B')
        end

        component.with_body_row do |row|
          row.with_cell('Body Cell A')
          row.with_cell('Body Cell B')
        end

        component.with_body_row do |row|
          row.with_cell('Body Cell C')
          row.with_cell('Body Cell D')
        end

        component.with_foot_row do |row|
          row.with_cell('Foot Cell A')
          row.with_cell('Foot Cell B')
        end
      end
    end

    it_behaves_like 'an application component' do
      let(:expected_classes) { classes }
      let(:expected_id) { id }
    end

    it 'has thead row' do
      expect(html).to have_css('table thead tr', count: 1)
    end

    it 'has thead header cells' do
      expect(html).to have_css('table thead tr th', text: 'Head Cell A')
      expect(html).to have_css('table thead tr th', text: 'Head Cell B')
    end

    it 'has tbody rows' do
      expect(html).to have_css('table tbody tr', count: 2)
    end

    it 'has tbody cells' do
      expect(html).to have_css('table tbody tr td', text: 'Body Cell A')
      expect(html).to have_css('table tbody tr td', text: 'Body Cell B')
      expect(html).to have_css('table tbody tr td', text: 'Body Cell C')
      expect(html).to have_css('table tbody tr td', text: 'Body Cell D')
    end

    it 'has tfoot row' do
      expect(html).to have_css('table tfoot tr', count: 1)
    end

    it 'has tfoot cells' do
      expect(html).to have_css('table tfoot tr td', text: 'Foot Cell A')
      expect(html).to have_css('table tfoot tr td', text: 'Foot Cell B')
    end
  end

  describe 'a table with rows' do
    let(:html) do
      render_inline(described_class.new(**params)) do |component|
        component.with_row do |row|
          row.with_header_cell('Head Cell A')
          row.with_header_cell('Head Cell B')
        end

        component.with_row do |row|
          row.with_cell('Cell A')
          row.with_cell('Cell B')
        end
      end
    end

    it 'has rows' do
      expect(html).to have_css('table tr', count: 2)
    end

    it 'has header cells' do
      expect(html).to have_css('table tr th', text: 'Head Cell A')
      expect(html).to have_css('table tr th', text: 'Head Cell B')
    end

    it 'has cells' do
      expect(html).to have_css('table tr td', text: 'Cell A')
      expect(html).to have_css('table tr td', text: 'Cell B')
    end
  end

  shared_examples 'a data cell with attributes' do |type: 'td'|
    it { expect(html).to have_css("table tr #{type}", text: 'Cell') }

    context 'with valid options' do
      it { expect(html).to have_css("table tr #{type}[colspan=\"2\"]") }
      it { expect(html).to have_css("table tr #{type}[rowspan=\"2\"]") }
      it { expect(html).to have_css("table tr #{type}[headers=\"header1\"]") }
      it { expect(html).to have_css("table tr #{type}[width=\"100px\"]") }
      it { expect(html).to have_css("table tr #{type}[height=\"50px\"]") }
    end

    context 'with invalid options' do
      let(:cell_param) { { invalid: 'value' } }

      it 'does not render invalid attributes' do
        expect(html).not_to have_css("table tr #{type}[invalid]")
      end
    end

    context 'with valid th options', if: type == 'th' do
      it { expect(html).to have_css('table tr th[scope="col"]') }
      it { expect(html).to have_css('table tr th[abbr="abbr"]') }
    end

    context 'with invalid scope', if: type == 'th' do
      let(:cell_param) { { scope: 'invalid' } }

      it 'does not render invalid scope' do
        expect { html }.to raise_error(ArgumentError, 'Invalid scope')
      end
    end
  end

  describe 'data cells' do
    let(:cell_param) { { colspan: 2, rowspan: 2, headers: 'header1', width: '100px', height: '50px' } }

    let(:html) do
      render_inline(described_class.new(**params)) do |component|
        component.with_row do |row|
          row.with_cell('Cell', **cell_param)
        end
      end
    end

    it_behaves_like 'a data cell with attributes'

    context 'with block content' do
      let(:html) do
        render_inline(described_class.new(**params)) do |component|
          component.with_row do |row|
            row.with_cell(**cell_param) do
              'Cell'
            end
          end
        end
      end

      it_behaves_like 'a data cell with attributes'
    end
  end

  describe 'header cells' do
    let(:cell_param) { { colspan: 2, rowspan: 2, headers: 'header1', width: '100px', height: '50px', scope: 'col', abbr: 'abbr' } }

    let(:html) do
      render_inline(described_class.new(**params)) do |component|
        component.with_row do |row|
          row.with_header_cell('Cell', **cell_param)
        end
      end
    end

    it_behaves_like 'a data cell with attributes', type: 'th'

    context 'with block content' do
      let(:html) do
        render_inline(described_class.new(**params)) do |component|
          component.with_row do |row|
            row.with_header_cell(**cell_param) do
              'Cell'
            end
          end
        end
      end

      it_behaves_like 'a data cell with attributes', type: 'th'
    end
  end
end
