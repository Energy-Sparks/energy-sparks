require 'rails_helper'

describe Cms::Section do
  describe '#search' do
    subject(:results) { described_class.search(query: query, show_all: show_all) }

    let(:query) { 'Lorem ipsum' }
    let(:show_all) { false }

    context 'when escaping the query' do
      let(:query) { 'Lorem ipsum?' }

      it 'finds results in title' do
        section = create(:section, title: query, published: true)
        expect(results.first).to eq(section)
      end
    end

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

    context 'when ranking results' do
      let(:query) { 'Lorem' }

      it 'returns in expected order' do
        ranked_lower = create(:section, title: 'Lorem ipsum', published: true)
        ranked_higher = create(:section, title: 'Lorem lorem ipsum. Ipsum Lorem. Lorem', published: true)
        expect(results.first).to eq(ranked_higher)
      end
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
