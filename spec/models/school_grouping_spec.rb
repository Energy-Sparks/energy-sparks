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

    ['area', 'project', 'diocese'].each do |role|
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

  shared_examples 'valid diocese role group types' do |group_type|
    let(:school_group) { create(:school_group, group_type:) }

    it 'is valid on create with role diocese' do
      grouping = described_class.new(school:, school_group:, role: 'diocese')
      expect(grouping).to be_valid
    end

    ['area', 'project', 'organisation'].each do |role|
      context "with #{role} role" do
        context 'when creating' do
          let!(:grouping) { described_class.new(school:, school_group:, role: role) }

          before do
            grouping.valid?
          end

          it_behaves_like 'it validates correctly', 'diocese'
        end
      end

      context 'when updating' do
        let!(:grouping) { described_class.create(school:, school_group:, role: 'diocese') }

        before do
          grouping.update(role:)
          grouping.valid?
        end

        it_behaves_like 'it validates correctly', 'diocese'
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

  shared_examples 'enforce one group per role per school' do |group_type, role|
    let(:trust) { create(:school_group, group_type: group_type) }

    context 'when creating' do
      let!(:grouping) { described_class.create(school:, school_group: trust, role:) }

      it { expect(grouping).to be_valid }
    end

    context 'when adding another organisation group' do
      let(:other) { create(:school_group, group_type: group_type) }

      let!(:grouping) { described_class.create(school:, school_group: trust, role:) }
      let!(:second_grouping) { described_class.create(school:, school_group: other, role:) }

      before do
        second_grouping.valid?
      end

      it 'prevents second grouping on create' do
        expect(second_grouping).to be_invalid
        #        expect(second_grouping.errors[:role]).to include('already has a organisation group assigned')
      end
    end
  end

  describe 'role-group_type compatibility' do
    %w[general local_authority multi_academy_trust].each do |group_type|
      context "when group_type is #{group_type}" do
        it_behaves_like 'valid organisation role group types', group_type
      end
    end

    context 'when group_type is local_authority_area' do
      it_behaves_like 'valid area role group types', :local_authority_area
    end

    context 'when group_type is diocese' do
      it_behaves_like 'valid diocese role group types', :diocese
    end
  end

  describe 'enforcing one organisation group per school' do
    it_behaves_like 'enforce one group per role per school', :multi_academy_trust, 'organisation'
  end

  describe 'enforcing one diocese group per school' do
    it_behaves_like 'enforce one group per role per school', :diocese, 'diocese'
  end

  describe 'enforcing one area group per school' do
    it_behaves_like 'enforce one group per role per school', :local_authority_area, 'area'
  end

  describe 'enforcing uniquess of school group relationship for projects' do
    let(:school_group) { create(:school_group, group_type: :project) }

    before do
      create(:school_grouping, school:, school_group:, role: 'project')
    end

    it 'is invalid when duplicating project grouping for same school and group' do
      duplicate = build(:school_grouping, school:, school_group:, role: 'project')
      expect(duplicate).not_to be_valid
    end

    it 'is valid when using a different group' do
      valid = build(:school_grouping, school:, school_group: create(:school_group, group_type: :project), role: 'project')
      expect(valid).to be_valid
    end

    it 'is valid when using a different school' do
      valid = build(:school_grouping, school: create(:school), school_group: school_group, role: 'project')
      expect(valid).to be_valid
    end
  end

  describe '.assign_diocese' do
    context 'when there is no matching group' do
      let!(:school) { create(:school, establishment: create(:establishment)) }

      before do
        described_class.assign_diocese(school)
      end

      it 'does nothing' do
        expect(school.reload.diocese).to be_nil
      end
    end

    context 'when there is no existing diocese' do
      let!(:school_group) { create(:school_group, dfe_code: 'CH01') }
      let!(:school) { create(:school, establishment: create(:establishment, diocese_code: 'CH01')) }

      before do
        described_class.assign_diocese(school)
      end

      it 'does nothing' do
        expect(school.reload.diocese).to be_nil
      end
    end

    context 'when there is no existing grouping' do
      let!(:school_group) { create(:school_group, group_type: :diocese, dfe_code: 'CH01') }
      let!(:school) { create(:school, establishment: create(:establishment, diocese_code: 'CH01')) }

      before do
        described_class.assign_diocese(school)
      end

      it 'add a relationship' do
        expect(school.reload.diocese).to eq(school_group)
      end
    end

    context 'when there is an existing grouping' do
      let!(:school_group) { create(:school_group, group_type: :diocese, dfe_code: 'CH01') }
      let!(:school) { create(:school, :with_diocese, establishment: create(:establishment, diocese_code: 'CH01')) }

      before do
        described_class.assign_diocese(school)
      end

      it 'updates the relationship' do
        expect(school.reload.diocese).to eq(school_group)
      end
    end
  end

  describe '.assign_area' do
    context 'when there is no matching group' do
      let!(:school) { create(:school, establishment: create(:establishment)) }

      before do
        described_class.assign_area(school)
      end

      it 'does nothing' do
        expect(school.reload.local_authority_area_group).to be_nil
      end
    end

    context 'when there is no existing local authority area' do
      let!(:school_group) { create(:school_group, dfe_code: '383') }
      let!(:school) { create(:school, establishment: create(:establishment, la_code: '383')) }

      before do
        described_class.assign_area(school)
      end

      it 'does nothing' do
        expect(school.reload.local_authority_area_group).to be_nil
      end
    end

    context 'when there is no existing grouping' do
      let!(:school_group) { create(:school_group, group_type: :local_authority_area, dfe_code: '383') }
      let!(:school) { create(:school, establishment: create(:establishment, la_code: '383')) }

      before do
        described_class.assign_area(school)
      end

      it 'add a relationship' do
        expect(school.reload.local_authority_area_group).to eq(school_group)
      end
    end

    context 'when there is an existing grouping' do
      let!(:school_group) { create(:school_group, group_type: :local_authority_area, dfe_code: '383') }
      let!(:school) { create(:school, :with_local_authority_area, establishment: create(:establishment, la_code: '383')) }

      before do
        described_class.assign_area(school)
      end

      it 'updates the relationship' do
        expect(school.reload.local_authority_area_group).to eq(school_group)
      end
    end
  end
end
