require 'rails_helper'

RSpec.describe ActivityTypeFilter, type: :service do

  let(:service) { ComparisonService.new(user) }
  let(:user)    { nil }

  describe '#list_scoreboards' do
    let!(:scoreboard)   { create(:scoreboard, name: 'Super scoreboard', public: true)}
    let!(:school)       { create(:school, :with_school_group, scoreboard: scoreboard) }

    let!(:private_scoreboard)   { create(:scoreboard, name: 'Private scoreboard', public: false)}
    let!(:other_school)       { create(:school, :with_school_group, scoreboard: private_scoreboard) }

    context 'as an admin' do
      let(:user)   { create(:admin) }
      it 'lists all scoreboards' do
        expect(service.list_scoreboards).to match_array([scoreboard, private_scoreboard])
      end
    end

    context 'as a guest' do
      it 'lists only public scoreboards' do
        expect(service.list_scoreboards).to match_array([scoreboard])
      end
    end

    context 'as a staff member in a school with private scoreboard' do
      let!(:user)         { create(:staff, school: other_school)}
      it 'lists public and private' do
        expect(service.list_scoreboards).to match_array([scoreboard, private_scoreboard])
      end
    end

    context 'as a staff member in a school with a public scoreboard' do
      let!(:user)         { create(:staff, school: school)}
      it 'lists only public' do
        expect(service.list_scoreboards).to match_array([scoreboard])
      end
    end

  end

  describe '#list_school_groups' do
    let(:school_group)  { create(:school_group, name: "Group", public: true)}
    let!(:school)       { create(:school, school_group: school_group) }

    let(:private_school_group)  { create(:school_group, name: "Private", public: false)}
    let!(:other_school)         { create(:school, school_group: private_school_group) }

    context 'as an admin' do
      let(:user)   { create(:admin) }
      it 'lists all groups' do
        expect(service.list_school_groups).to match_array([school_group, private_school_group])
      end
    end

    context 'as a guest' do
      it 'lists only public groups' do
        expect(service.list_school_groups).to match_array([school_group])
      end
    end

    context 'as a staff member in a school with private group' do
      let!(:user)         { create(:staff, school: other_school)}
      it 'lists public and private' do
        expect(service.list_school_groups).to match_array([school_group, private_school_group])
      end
    end

    context 'as a staff member in a school with a public group' do
      let!(:user)         { create(:staff, school: school)}
      it 'lists only public' do
        expect(service.list_school_groups).to match_array([school_group])
      end
    end

  end
end
