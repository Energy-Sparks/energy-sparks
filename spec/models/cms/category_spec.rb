require 'rails_helper'

describe Cms::Category do
  describe '#publishable?' do
    subject(:category) { create(:category) }

    context 'with no pages' do
      it { expect(category.publishable?).to be(false) }
    end

    context 'with no published pages' do
      subject(:category) { create(:category, :with_pages, pages_published: false) }

      it { expect(category.publishable?).to be(false) }
    end

    context 'with published pages' do
      subject(:category) { create(:category, :with_pages, pages_published: true) }

      it { expect(category.publishable?).to be(true) }
    end
  end

  describe 'change publication status' do
    before do
      category.toggle(:published)
    end

    context 'when not published' do
      let(:published) { false }

      context 'with no pages' do
        subject(:category) { create(:category, published: published) }

        it { expect(category.save).to be(false) }
        it { expect { category.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Published Cannot publish category without any published pages') }
      end

      context 'with no published pages' do
        subject(:category) { create(:category, :with_pages, published: published, pages_published: false) }

        it { expect(category.save).to be(false) }
        it { expect { category.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Published Cannot publish category without any published pages') }
      end

      context 'with published pages' do
        subject(:category) { create(:category, :with_pages, published: published, pages_published: true) }

        it { expect(category.save).to be(true) }
      end
    end

    context 'when published' do
      let(:published) { true }

      context 'with no pages' do
        subject(:category) { create(:category, published: published) }

        it { expect(category.save).to be(true) }
      end

      context 'with no published pages' do
        subject(:category) { create(:category, :with_pages, published: published, pages_published: false) }

        it { expect(category.save).to be(true) }
      end

      context 'with published pages' do
        subject(:category) { create(:category, :with_pages, published: published, pages_published: true) }

        it { expect(category.save).to be(true) }
      end
    end
  end
end
