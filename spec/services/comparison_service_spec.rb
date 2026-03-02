require 'rails_helper'

RSpec.describe ActivityTypeFilter, type: :service do
  let(:service) { ComparisonService.new(user) }
  let(:user)    { nil }

  describe '#list_scoreboards' do
    let!(:scoreboard)   { create(:scoreboard, name: 'Super scoreboard', public: true) }
    let!(:school)       { create(:school, :with_school_group, scoreboard: scoreboard) }

    let!(:private_scoreboard) { create(:scoreboard, name: 'Private scoreboard', public: false) }
    let!(:other_school) { create(:school, :with_school_group, scoreboard: private_scoreboard) }

    context 'as an admin' do
      let(:user)   { create(:admin) }

      it 'lists all scoreboards' do
        expect(service.list_scoreboards).to contain_exactly(scoreboard, private_scoreboard)
      end
    end

    context 'as a guest' do
      it 'lists only public scoreboards' do
        expect(service.list_scoreboards).to contain_exactly(scoreboard)
      end
    end

    context 'as a staff member in a school with private scoreboard' do
      let!(:user) { create(:staff, school: other_school) }

      it 'lists public and private' do
        expect(service.list_scoreboards).to contain_exactly(scoreboard, private_scoreboard)
      end
    end

    context 'as a staff member in a school with a public scoreboard' do
      let!(:user) { create(:staff, school: school) }

      it 'lists only public' do
        expect(service.list_scoreboards).to contain_exactly(scoreboard)
      end
    end
  end

  describe '#list_school_groups' do
    let!(:school_groups) do
      groups = { public: create(:school_group, name: 'Group', public: true),
                 private: create(:school_group, name: 'Private', public: false),
                 project: create(:school_group, :project_group, :with_active_schools, name: 'Project') }
      create(:school, school_group: groups[:public])
      create(:school, school_group: groups[:private])
      groups
    end

    context 'when an admin' do
      let(:user) { create(:admin) }

      it 'lists all groups' do
        expect(service.list_school_groups).to match_array(school_groups.values)
      end
    end

    context 'when a guest' do
      it 'lists only public groups' do
        expect(service.list_school_groups).to contain_exactly(school_groups[:public])
      end
    end

    context 'when a staff member in a school with a private group' do
      let(:user) { create(:staff, school: school_groups[:private].schools.first) }

      it 'lists public and private' do
        expect(service.list_school_groups).to contain_exactly(school_groups[:public], school_groups[:private])
      end
    end

    context 'when a staff member in a school with a public group' do
      let(:user) { create(:staff, school: school_groups[:public].schools.first) }

      it 'lists only public' do
        expect(service.list_school_groups).to contain_exactly(school_groups[:public])
      end
    end
  end
end
