# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BreadcrumbsComponent, type: :component do
  let(:last) { list_items.last }
  let(:first) { list_items.first }

  shared_examples_for 'a selected last item' do
    it { expect(last).to have_text(text) }
    it { expect(last).not_to have_link(text) }
    it { expect(last).to have_selector('.active') }
    it { expect(last).to have_css("li[aria-current='page']") }
  end

  context 'when there is a school and no items' do
    let(:list_items) do
      render_inline(BreadcrumbsComponent.new) do |c|
        c.with_school(school)
      end.css('li')
    end

    context 'and the school has a school group' do
      let(:school) { create(:school, :with_school_group) }

      it { expect(list_items.count).to eq(3) }

      it 'links to all schools' do
        expect(list_items.first).to have_link('Schools', href: '/schools')
      end

      it 'links to school group' do
        expect(list_items[1]).to have_link(school.school_group.name, href: "/school_groups/#{school.school_group.slug}")
      end

      it_behaves_like 'a selected last item' do
        let(:text) { school.name }
      end
    end

    context "school doesn't have a school group" do
      let(:school) { create(:school) }

      it { expect(list_items.count).to eq(2) }

      it 'links to all schools' do
        expect(list_items.first).to have_link('Schools', href: '/schools')
      end

      it_behaves_like 'a selected last item' do
        let(:text) { school.name }
      end
    end
  end

  context 'when there are items and no school' do
    let(:list_items) do
      render_inline(BreadcrumbsComponent.new) do |c|
        c.with_items([
                       { name: 'Advice', href: 'school_advice_url' },
                       { name: 'Baseload', href: 'school_advice_baseload_url' }
                     ])
      end.css('li')
    end

    it { expect(list_items.count).to eq(2) }

    it 'links to first item' do
      expect(list_items.first).to have_link('Advice', href: 'school_advice_url')
    end

    it_behaves_like 'a selected last item' do
      let(:text) { 'Baseload' }
    end
  end

  context 'when there is a school and items' do
    let(:school) { create(:school, :with_school_group) }
    let(:list_items) do
      render_inline(BreadcrumbsComponent.new) do |c|
        c.with_school(school)
        c.with_items([
                       { name: 'Advice', href: 'school_advice_url' },
                       { name: 'Baseload', href: 'school_advice_baseload_url' }
                     ])
      end.css('li')
    end

    it { expect(list_items.count).to eq(5) }

    it 'links to all schools' do
      expect(list_items.first).to have_link('Schools', href: '/schools')
    end

    it 'links to school group' do
      expect(list_items[1]).to have_link(school.school_group.name, href: "/school_groups/#{school.school_group.slug}")
    end

    it 'links to school' do
      expect(list_items[2]).to have_link(school.name, href: "/schools/#{school.slug}")
    end

    it 'links to first item' do
      expect(list_items[3]).to have_link('Advice', href: 'school_advice_url')
    end

    it_behaves_like 'a selected last item' do
      let(:text) { 'Baseload' }
    end
  end

  context 'conditional items' do
    let(:href) { 'a_link' }
    let(:list_items) do
      render_inline(BreadcrumbsComponent.new) do |c|
        c.with_items([
                       { name: 'Electricty', href: href, visible: visible },
                       { name: 'First item', href: 'a_link' }
                     ])
      end.css('li')
    end

    context 'when item is visible' do
      let(:visible) { true }

      it { expect(first).to have_link('Electricty') }

      context 'and there is no link' do
        let(:href) { nil }

        it { expect(first).to have_text('Electricty') }
        it { expect(first).not_to have_link('Electricty') }
      end
    end

    context 'when item is not visible' do
      let(:visible) { false }

      it { expect(first).not_to have_link('Electricty') }
    end
  end
end
