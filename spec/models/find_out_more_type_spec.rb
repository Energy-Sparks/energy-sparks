require 'rails_helper'

describe AlertTypeRating, type: :model do
  describe 'valid?' do
    it 'is valid with the factory attributes' do
      expect(build(:alert_type_rating)).to be_valid
    end

    describe 'ratings' do
      it 'is not valid with ratings out of order' do
        expect(build(:alert_type_rating, rating_from: 9, rating_to: 7)).not_to be_valid
      end

      it 'is valid with equal from to' do
        expect(build(:alert_type_rating, rating_from: 7, rating_to: 7)).not_to be_valid
      end

      it 'is not valid with ratings out of range' do
        expect(build(:alert_type_rating, rating_from: -1, rating_to: 7)).not_to be_valid
        expect(build(:alert_type_rating, rating_from: 1, rating_to: 11)).not_to be_valid
      end
    end
  end
end
