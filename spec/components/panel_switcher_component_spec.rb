# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PanelSwitcherComponent, type: :component, include_url_helpers: true do
  let(:all_params) { { title: 'Title text', description: 'Description text', selected: 'name_2', classes: 'my-class', id: 'my-id' } }
  let(:panels) { html.css('div.panel') }
  let(:radios) { html.css("input[type='radio']") }
  let(:html) do
    render_inline(PanelSwitcherComponent.new(**params)) do |c|
      c.with_panel(name: 'name_1', label: 'Label 1') { 'Content 1' }
      c.with_panel(name: 'name_2', label: 'Label 2') { 'Content 2' }
      c.with_panel(name: 'name_3', label: 'Label 3') { 'Content 3' }
    end
  end

  context 'with no panels' do
    let(:params) { all_params }
    let(:html) do
      render_inline(PanelSwitcherComponent.new(**params))
    end

    it "doesn't render" do
      expect(html.to_s).to be_blank
    end
  end

  context 'with all params' do
    let(:params) { all_params }

    it { expect(html).to have_selector('h4 strong', text: 'Title text') }
    it { expect(html).to have_selector('div.panel-switcher-component>p', text: 'Description text') }

    it 'adds specified classes' do
      expect(html).to have_css('div.panel-switcher-component.my-class')
    end

    it 'adds specified id' do
      expect(html).to have_css('div.panel-switcher-component#my-id')
    end

    it 'checks the selected radio button' do
      expect(html).to have_checked_field('Label 2')
      expect(html).to have_unchecked_field('Label 1')
      expect(html).to have_unchecked_field('Label 3')
    end

    it 'shows selected panel' do
      expect(html).to have_selector('.panel.name_2', visible: :visible)
    end

    it 'hides other panel' do
      expect(html).to have_selector('.panel.name_1', visible: :hidden)
      expect(html).to have_selector('.panel.name_3', visible: :hidden)
    end
  end

  context "when selected doesn't exist" do
    let(:params) { all_params.merge({ selected: 'not_found' }) }

    it 'selects the first one' do
      expect(html).to have_checked_field('Label 1')
    end

    it 'others are unselected' do
      expect(html).to have_unchecked_field('Label 2')
      expect(html).to have_unchecked_field('Label 3')
    end
  end

  context "when one panel is empty" do
    let(:params) { all_params }

    let(:html) do
      render_inline(PanelSwitcherComponent.new(**params)) do |c|
        c.with_panel(name: 'name_1', label: 'Label 1') { 'Content 1' }
        c.with_panel(name: 'name_2', label: 'Label 2') { '' }
      end
    end

    it "displays the panel with content" do
      expect(html).to have_selector('.panel.name_1', visible: :visible)
    end

    it "selects the radio button for the panel with content" do
      expect(html).to have_checked_field("Label 1")
    end

    it "does not display the empty panel" do
      expect(html).not_to have_selector('.panel.name_2', visible: :visible)
    end

    it "does not display radio button for the empty panel" do
      expect(html).not_to have_field("Label 2")
    end
  end

  context 'with default parameters' do
    let(:params) { all_params.except(:title, :description, :selected, :classes, :id) }

    it 'does not display title' do
      expect(html).not_to have_selector('h4 strong')
    end

    it 'does not display description' do
      expect(html).not_to have_selector('div.panel-switcher-component>p')
    end

    it 'does not add css' do
      expect(html).not_to have_css('div.panel-switcher-component.my-class')
    end

    it 'does not add id' do
      expect(html).not_to have_css('div.panel-switcher-component#my-id')
    end

    it 'checks the first radio by default' do
      expect(html).to have_checked_field('Label 1')
    end

    it 'shows selected panel' do
      expect(html).to have_selector('.panel.name_1', visible: :visible)
    end

    it 'hides other panels' do
      expect(html).to have_selector('.panel.name_2', visible: :hidden)
      expect(html).to have_selector('.panel.name_3', visible: :hidden)
    end
  end
end
