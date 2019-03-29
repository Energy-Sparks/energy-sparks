require 'rails_helper'

describe FindOutMoreType, type: :model do
  describe 'valid?' do
    it 'is valid with the factory attributes' do
      expect(build(:find_out_more_type)).to be_valid
    end

    describe 'ratings' do
      it 'is not valid with ratings out of order' do
        expect(build(:find_out_more_type, rating_from: 9, rating_to: 7)).to_not be_valid
      end

      it 'is valid with equal from to' do
        expect(build(:find_out_more_type, rating_from: 7, rating_to: 7)).to_not be_valid
      end

      it 'is not valid with ratings out of range' do
        expect(build(:find_out_more_type, rating_from: -1, rating_to: 7)).to_not be_valid
        expect(build(:find_out_more_type, rating_from: 1, rating_to: 11)).to_not be_valid
      end
    end
  end
end
