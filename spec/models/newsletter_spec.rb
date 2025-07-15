require 'rails_helper'

RSpec.describe Newsletter, type: :model do
  describe '.without_images' do
    context 'when all newsletters have images attached' do
      let!(:newsletters) { create_list(:newsletter, 2, image: fixture_file_upload('spec/fixtures/images/laptop.jpg')) }

      it 'returns nothing' do
        expect(Newsletter.without_images).to be_empty
      end
    end

    context 'when some newsletters do not have images attached' do
      let!(:newsletter_with_image) { create(:newsletter, image: fixture_file_upload('spec/fixtures/images/laptop.jpg')) }
      let!(:newsletter_without_image) { build(:newsletter, image: nil).tap { |cs| cs.save(validate: false) } }

      it 'returns only newsletters without images' do
        expect(Newsletter.without_images).to contain_exactly(newsletter_without_image)
      end
    end

    context 'when no newsletters have images attached' do
      let!(:newsletters) { build_list(:newsletter, 2, image: nil).each { |n| n.save(validate: false) } }

      it 'returns all newsletters' do
        expect(Newsletter.without_images).to match_array(newsletters)
      end
    end

    context 'when there are no newsletters' do
      it 'returns an empty ActiveRecord::Relation' do
        expect(Newsletter.without_images).to be_empty
      end
    end
  end

  context 'when attempting to publish with no image' do
    let!(:newsletter_no_image) { create(:newsletter, image: nil, published: false) }

    it 'raises' do
      newsletter_no_image.published = true
      expect { newsletter_no_image.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
