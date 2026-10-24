# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::TranslationFlagComponent, type: :component do
  let(:record) { build(:label, name: 'Save energy', name_cy: welsh_name) }
  let(:welsh_name) { nil }

  context 'when the record has not been translated' do
    before { render_inline(described_class.new(record: record, field: :name, locale: :cy)) }

    it 'shows a greyed out flag with a tooltip' do
      expect(page).to have_css("span[title='No Welsh translation'] i.fa-flag.text-grey-light")
    end
  end

  context 'when the record has been translated' do
    let(:welsh_name) { 'Arbed ynni' }

    before { render_inline(described_class.new(record: record, field: :name, locale: :cy)) }

    it 'shows a flag with a tooltip containing the translation' do
      expect(page).to have_css("span[title='Translated: Arbed ynni'] i.fa-flag.text-success")
    end
  end

  context 'when the translation is longer than the tooltip' do
    let(:welsh_name) { 'This Welsh name is quite long' }

    before { render_inline(described_class.new(record: record, field: :name, locale: :cy)) }

    it 'truncates the translation in the tooltip' do
      expect(page).to have_css("span[title='Translated: This Welsh name is qui...'] i.fa-flag.text-success")
    end
  end

  context 'when the translation is rich text' do
    let(:record) { double(description_cy: ActionText::Content.new('<p>Some <strong>rich</strong> text</p>')) }

    before { render_inline(described_class.new(record: record, field: :description, locale: :cy)) }

    it 'shows the plain text of the translation' do
      expect(page).to have_css("span[title='Translated: Some rich text'] i.fa-flag.text-success")
    end
  end

  context 'when the translation is an attachment' do
    let(:record) { double(image_cy: double(filename: 'welsh-image.jpg')) }

    before { render_inline(described_class.new(record: record, field: :image, locale: :cy)) }

    it 'shows the filename of the translation' do
      expect(page).to have_css("span[title='Translated: welsh-image.jpg'] i.fa-flag.text-success")
    end
  end

  context 'when the record does not translate the field' do
    let(:record) { double }

    before { render_inline(described_class.new(record: record, field: :name, locale: :cy)) }

    it 'shows a greyed out flag with a tooltip' do
      expect(page).to have_css("span[title='No Welsh translation'] i.fa-flag.text-grey-light")
    end
  end
end
