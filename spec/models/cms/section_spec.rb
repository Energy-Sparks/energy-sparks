require 'rails_helper'

describe Cms::Section do
  describe '#search' do
    subject(:results) { described_class.search(query: query, show_all: show_all) }

    let(:query) { 'Lorem ipsum' }
    let(:show_all) { false }

    it 'finds results in title' do
      section = create(:section, title: query, published: true)
      expect(results.first).to eq(section)
    end

    it 'finds results in body' do
      section = create(:section, body: query, published: true)
      expect(results.first).to eq(section)
    end

    it 'ignores unpublished' do
      section = create(:section, title: query, published: false)
      expect(results).to be_empty
    end

    context 'when searching for unpublished' do
      let(:show_all) { true }

      it 'finds results' do
        section = create(:section, title: query, published: true)
        expect(results.first).to eq(section)
      end
    end
  end
end
