# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport do
  subject(:report) { described_class.new(school_group) }

  let(:school_group) { create(:school_group) }
  let!(:visible_school) { create(:school, data_enabled: false, school_group:) }
  let!(:data_visible_school) { create(:school, school_group:) }

  describe '#visible_schools' do
    it 'returns only visible schools assigned to the school group' do
      expect(report.visible_schools).to contain_exactly(visible_school, data_visible_school)
    end
  end

  describe '#data_visible_schools' do
    before { create(:school, :with_school_group) }

    it 'returns only data-visible schools assigned to the school group' do
      expect(report.data_visible_schools).to eq([data_visible_school])
    end
  end

  describe '#overview' do
    subject(:overview) { report.overview }

    describe '#users' do
      context 'with school users' do
        let!(:school_user) { create(:user, school: visible_school) }

        it 'includes users belonging to visible schools' do
          expect(overview.users).to eq([school_user])
        end
      end

      context 'with school group users' do
        let!(:group_user) { create(:user, school_group:) }

        it 'includes users belonging to the school group' do
          expect(overview.users).to include(group_user)
        end
      end

      context 'with cluster school users' do
        let!(:cluster_user) { create(:school_admin, :with_cluster_schools, existing_school: visible_school) }

        it 'includes cluster school users for visible schools' do
          expect(overview.users).to include(cluster_user)
        end
      end

      it 'excludes users from non-visible schools' do
        hidden_user = create(:user, school: create(:school, visible: false, school_group:))
        expect(overview.users).not_to include(hidden_user)
      end
    end

    describe '#active_users' do
      it 'returns the count of users who have logged in within the last three months' do
        active_user   = create(:user, school: visible_school, last_sign_in_at: 1.month.ago)
        inactive_user = create(:user, school: visible_school, last_sign_in_at: 6.months.ago)

        expect(overview.users).to include(active_user, inactive_user)
        expect(overview.active_users).to eq(1)
      end
    end

    describe '#pupils' do
      it 'returns the total number of pupils across all visible schools' do
        create(:school, visible: false, school_group:, number_of_pupils: 200)
        visible_school.update(number_of_pupils: 1)
        data_visible_school.update(number_of_pupils: 1)
        expect(overview.pupils).to eq(2)
      end
    end

    describe '#enrolled_schools' do
      it 'counts onboardings completed within the last 12 months' do
        create(:school_onboarding, :with_completed, school_group:)
        expect(overview.enrolled_schools).to eq(1)
      end

      it 'excludes onboardings completed more than 12 months ago' do
        create(:school_onboarding, :with_completed, school_group:, completed_on: 13.months.ago)
        expect(overview.enrolled_schools).to eq(0)
      end
    end

    describe '#enrolling_schools' do
      it 'counts onboardings that are still incomplete' do
        create(:school_onboarding, school_group:)
        expect(overview.enrolling_schools).to eq(1)
      end

      it 'excludes completed onboardings' do
        create(:school_onboarding, :with_completed, school_group:)
        expect(overview.enrolling_schools).to eq(0)
      end
    end
  end
end
