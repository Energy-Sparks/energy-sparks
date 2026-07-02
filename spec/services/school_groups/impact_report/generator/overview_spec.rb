# frozen_string_literal: true

require 'rails_helper'

describe SchoolGroups::ImpactReport::Generator::Overview do
  subject(:overview) { described_class.new(school.school_group, visible_schools) }

  let(:school) { create(:school, :with_school_group) }
  let(:visible_schools) { school.school_group.assigned_schools.visible }
  let(:school_group) { school.school_group }

  describe '#metrics' do
    subject(:metrics) do
      overview.metrics.index_by { |metric| metric[:metric_type] }
                      .transform_values { |u| u.except(:metric_type) }
    end

    def expected(**)
      { enough_data: true, fuel_type: nil, unit: nil, metric_category: :overview, number_of_schools: 1, value: 1 }
        .merge(**)
    end

    context 'with users' do
      context 'with school users' do
        before { create(:user, school:) }

        it 'includes users belonging to visible schools' do
          expect(metrics[:users]).to eq(expected)
        end
      end

      context 'with school group users' do
        before { create(:user, school_group:) }

        it 'includes users belonging to the school group' do
          expect(metrics[:users]).to eq(expected)
        end
      end

      context 'with cluster school users' do
        before { create(:school_admin, :with_cluster_schools, existing_school: school) }

        it 'includes cluster school users for visible schools' do
          expect(metrics[:users]).to eq(expected)
        end
      end

      context 'with non visible schools' do
        before { create(:user, school: create(:school, visible: false, school_group:)) }

        it 'shows no users' do
          expect(metrics[:users]).to eq(expected(value: 0))
        end
      end

      context 'with pupils' do
        before { create(:pupil, school:) }

        it 'shows no users' do
          expect(metrics[:users]).to eq(expected(value: 0))
        end
      end

      context 'with non active' do
        before { create(:user, school:, active: false) }

        it 'shows no users' do
          expect(metrics[:users]).to eq(expected(value: 0))
        end
      end

      context 'with non confirmed' do
        before { create(:user, school:, confirmed_at: nil) }

        it 'shows no users' do
          expect(metrics[:users]).to eq(expected(value: 0))
        end
      end
    end

    context 'with active_users' do
      before do
        create(:user, school:, last_sign_in_at: 1.month.ago)
        create(:user, school:, last_sign_in_at: 6.months.ago)
      end

      it 'returns the count of users who have logged in within the last three months' do
        expect(metrics[:users]).to eq(expected(value: 2))
        expect(metrics[:active_users]).to eq(expected)
      end
    end

    context 'with pupils' do
      before do
        create(:school, visible: false, school_group:, number_of_pupils: 200)
        create(:school, data_enabled: false, school_group:, number_of_pupils: 1)
        school.update!(number_of_pupils: 1)
      end

      it 'returns the total number of pupils across all visible schools' do
        expect(metrics[:pupils]).to eq(expected(number_of_schools: 2, value: 2))
      end
    end

    context 'with enrolled_schools' do
      context 'with onboardings completed within the last 12 months' do
        before { create(:school_onboarding, :with_completed, school_group:) }

        it 'counts correctly' do
          expect(metrics[:enrolled_schools]).to eq(expected)
        end
      end

      context 'with onboardings completed more than 12 months ago' do
        before { create(:school_onboarding, :with_completed, school_group:, completed_on: 13.months.ago) }

        it 'is zero' do
          expect(metrics[:enrolled_schools]).to eq(expected(value: 0))
        end
      end
    end

    context 'with enrolling_schools' do
      context 'with onboardings that are still incomplete' do
        before { create(:school_onboarding, school_group:) }

        it 'counts correctly' do
          expect(metrics[:enrolling_schools]).to eq({ enough_data: true, fuel_type: nil, metric_category: :overview,
                                                      number_of_schools: 1, value: 1, unit: nil })
        end
      end

      context 'with completed onboardings' do
        before { create(:school_onboarding, :with_completed, school_group:) }

        it 'is zero' do
          expect(metrics[:enrolling_schools]).to eq({ enough_data: true, fuel_type: nil, metric_category: :overview,
                                                      number_of_schools: 1, value: 0, unit: nil })
        end
      end
    end
  end
end
