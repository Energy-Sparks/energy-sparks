require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#manages_school?' do
    context 'user role is school_admin' do
      context 'user is not associated with a school' do
        it 'returns false' do
          user = FactoryGirl.create :user, role: :school_admin
          expect(user.manages_school?).to be_falsey
        end
      end
      context 'user is associated with a school' do
        it 'returns true' do
          user = FactoryGirl.create :user, :has_school_assigned, role: :school_admin
          expect(user.manages_school?).to be_truthy
        end
      end
    end
    context 'user role is guest' do
      it 'returns false' do
        user = FactoryGirl.create :user, role: :guest
        expect(user.manages_school?).to be_falsey
      end
    end
    context 'user role is admin' do
      it 'returns false' do
        user = FactoryGirl.create :user, role: :admin
        expect(user.manages_school?).to be_falsey
      end
    end
  end
end
