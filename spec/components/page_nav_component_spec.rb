# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PageNavComponent, type: :component do
  let(:all_header_params) { { name: 'Name', icon: 'bars', href: 'link', classes: 'bg-header' } }
  let(:all_section_params) { { name: 'Section Name', icon: 'bolt', visible: true, classes: 'bg-section' } }
  let(:all_item_params) { { name: 'Item Name', href: '/schools/index' } }
  let(:list_items) { page_nav.css('li') }

  context 'Header' do
    let(:page_nav) { render_inline(PageNavComponent.new(**header_params)) }

    subject(:list_item) { list_items.first }

    context 'with all params' do
      let(:header_params) { all_header_params }

      it { expect(list_items.count).to eq(1) }
      it { expect(list_item).to have_link('Name', href: 'link') }
      it { expect(list_item).to have_css('i.fa-bars') }
      it { expect(list_item).to have_css('.bg-header') }
      it { expect(list_item).to have_css('.nav-link') }
    end

    context 'with defaults' do
      let(:header_params) { all_header_params.except(:name, :icon, :classes) }

      it { expect(list_item).to have_link('Menu', href: 'link') }
      it { expect(list_item).to have_css('i.fa-home') }
    end

    context 'with no icon' do
      let(:header_params) { { href: 'link' } }

      it { expect(list_item).to have_link('Menu', href: 'link') }
    end
  end

  context 'Section' do
    let(:header_params)  { all_header_params }
    let(:section_params) { all_section_params }
    subject(:list_item)  { list_items[1] }

    let(:page_nav) do
      render_inline(PageNavComponent.new(**header_params)) do |c|
        c.with_section(**section_params)
      end
    end

    context 'with all params' do
      it { expect(list_item).to have_link('Section Name') }
      it { expect(list_item).to have_css('i.fa-bolt') }
      it { expect(list_item).to have_css('.bg-section') }
      it { expect(list_item).to have_css('.nav-link') }
      it { expect(list_item).to have_css('.nav-text') }
      it { expect(list_item).to have_css('.toggler') }
      it { expect(list_item).to have_css('.nav-toggle-icons') }
      it { expect(page_nav).to have_css('.page-nav-component') } # css based on this
    end

    context 'without toggling for section' do
      let(:section_params) { { name: 'Section Name', toggler: false, visible: true, classes: 'bg-section' } }

      it { expect(list_item).not_to have_css('.toggler') }
    end

    context 'with no name' do
      let(:section_params) { all_section_params.except(:name) }

      it "doesn't show section header" do
        expect(list_item).not_to have_link
      end
    end

    context 'with visible set to false' do
      let(:section_params) { all_section_params.update(visible: false) }

      it "doesn't show section header" do
        expect(list_item).not_to have_link
      end
    end

    context 'with no items' do
      it { expect(list_items.count).to eq(2) }
    end

    context 'with items' do
      let(:item_params) { all_item_params }
      let(:page_nav) do
        with_controller_class SchoolsController do
          with_request_url '/schools/index' do
            render_inline(PageNavComponent.new(**header_params)) do |c|
              c.with_section(**section_params) do |s|
                s.with_item(**item_params)
              end
            end
          end
        end
      end

      subject(:list_item) { list_items[2] }

      it { expect(list_item).to have_css('.nav-link') }
      it { expect(list_item).to have_css('.nav-text') }
      it { expect(list_item).to have_link('Item Name', href: '/schools/index') }
      it { expect(list_item).to have_css('.current') }

      context 'with note on item' do
        let(:item_params) { all_item_params.update(note: '(X)') }

        it { expect(list_item).to have_css('.nav-toggle-icons') }
        it { expect(list_item).to have_content('(X)') }
      end

      context 'with match_controller set to false (default)' do
        let(:item_params) { all_item_params.update(href: '/schools/new')}

        it { expect(list_item).not_to have_css('.current') }
      end

      context 'with match_controller set to true for the item' do
        let(:item_params) { all_item_params.update(href: '/schools/new', match_controller: true)}

        it { expect(list_item).to have_css('.current') }
      end

      context 'with selected set to true for the item' do
        let(:item_params) { all_item_params.update(href: '/schools/new', selected: true)}

        it { expect(list_item).to have_css('.current') }
      end

      context 'with visible set to false for the item' do
        let(:item_params) { all_item_params.update(href: '/schools/new', visible: false)}

        it { expect(list_item).not_to have_link('Item Name') }
      end

      context 'with visible set to true for the item' do
        let(:item_params) { all_item_params.update(href: '/schools/new', visible: true)}

        it { expect(list_item).to have_link('Item Name') }
      end

      context 'with match_controller page nav option set to true' do
        let(:header_params) { all_header_params.update(options: { match_controller: true }) }
        let(:item_params) { all_item_params.update(href: '/schools/new')}

        it { expect(list_item).to have_css('.current') }
      end
    end
  end

  pending 'CollapseButton testing to be completed after decided on responsive behaviour'
end
