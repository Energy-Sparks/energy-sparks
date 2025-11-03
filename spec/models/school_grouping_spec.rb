require 'rails_helper'

describe SchoolGrouping do
  let(:school) { create(:school) }

  shared_examples 'it validates correctly' do |role|
    it 'is invalid on create' do
      expect(grouping).to be_invalid
    end

    it 'has correct error message' do
      expect(grouping.errors[:role]).to include("must be #{role} for this group type")
    end
  end

  shared_examples 'valid organisation role group types' do |group_type|
    let(:school_group) { create(:school_group, group_type:) }

    it 'is valid on create with role organisation' do
      grouping = described_class.new(school:, school_group:, role: 'organisation')
      expect(grouping).to be_valid
    end

    ['area', 'project'].each do |role|
      context "with #{role} role" do
        context 'when creating' do
          let!(:grouping) { described_class.new(school:, school_group:, role: role) }

          before do
            grouping.valid?
          end

          it_behaves_like 'it validates correctly', 'organisation'
        end
      end

      context 'when updating' do
        let!(:grouping) { described_class.create(school:, school_group:, role: 'organisation') }

        before do
          grouping.update(role:)
          grouping.valid?
        end

        it_behaves_like 'it validates correctly', 'organisation'
      end
    end
  end

  shared_examples 'valid area role group types' do |group_type|
    let(:school_group) { create(:school_group, group_type:) }

    it 'is valid on create with role area' do
      grouping = described_class.new(school:, school_group:, role: 'area')
      expect(grouping).to be_valid
    end

    ['organisation', 'project'].each do |role|
      context "with #{role} role" do
        context 'when creating' do
          let(:grouping) { described_class.create(school:, school_group:, role: role) }

          before do
            grouping.valid?
          end

          it_behaves_like 'it validates correctly', 'area'
        end

        context 'when updating' do
          let!(:grouping) { described_class.create(school:, school_group:, role: role) }

          before do
            grouping.update(role:)
            grouping.valid?
          end

          it_behaves_like 'it validates correctly', 'area'
        end
      end
    end
  end

  describe 'role-group_type compatibility' do
    %w[general local_authority multi_academy_trust].each do |group_type|
      context "when group_type is #{group_type}" do
        it_behaves_like 'valid organisation role group types', group_type
      end
    end

    %w[diocese local_authority_area].each do |group_type|
      context "when group_type is #{group_type}" do
        it_behaves_like 'valid area role group types', group_type
      end
    end
  end

  describe 'enforcing one organisation group per school' do
    let(:trust) { create(:school_group, group_type: :multi_academy_trust) }

    context 'when creating' do
      let!(:grouping) { described_class.create(school:, school_group: trust, role: 'organisation') }

      it { expect(grouping).to be_valid }
    end

    context 'when adding another organisation group' do
      let(:general) { create(:school_group, group_type: :general) }

      let!(:grouping) { described_class.create(school:, school_group: trust, role: 'organisation') }
      let!(:second_grouping) { described_class.create(school:, school_group: general, role: 'organisation') }

      before do
        second_grouping.valid?
      end

      it 'prevents second organisation grouping on create' do
        expect(second_grouping).to be_invalid
        expect(second_grouping.errors[:role]).to include('already has a organisation group assigned')
      end
    end
  end
end
