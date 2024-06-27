require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  shared_examples 'a user who cannot manage site wide content' do
    %w(ActivityType ActivityCategory SchoolTarget).each do |thing|
      it { is_expected.not_to be_able_to(:manage, thing.constantize.new) }
    end
  end

  shared_examples 'they cannot access the school dashboard and data' do
    %i[show].each do |action|
      it { is_expected.not_to be_able_to(action, school) }
    end
    it { is_expected.not_to be_able_to(:show_pupils_dash, school)}
    it { is_expected.not_to be_able_to(:download_school_data, school) }
    it { is_expected.not_to be_able_to(:show_management_dash, school) }
    it { is_expected.not_to be_able_to(:read_restricted_analysis, school) }
  end

  shared_examples 'they can access the school dashboard and data' do
    %i[index show].each do |action|
      it { is_expected.to be_able_to(action, school) }
    end
    it { is_expected.to be_able_to(:show_pupils_dash, school)}
    it { is_expected.to be_able_to(:download_school_data, school) }
    it { is_expected.to be_able_to(:show_management_dash, school) }
  end

  shared_examples 'they can record activities for their school' do
    it { is_expected.to be_able_to(:manage, Activity.new(school: school)) }
    it { is_expected.to be_able_to(:read, ActivityCategory.new) }
    it { is_expected.to be_able_to(:show, ActivityType.new) }
  end

  shared_examples 'they can set targets' do
    it { is_expected.to be_able_to(:manage, create(:school_target, school: school)) }
  end

  shared_examples 'a user who can manage users for their school' do
    it 'can manage another school admin for this school' do
      expect(subject).to be_able_to(:manage, create(:school_admin, school: school))
    end

    it 'can manage cluster admin for this school' do
      expect(subject).to be_able_to(:manage, create(:school_admin, cluster_schools: [school]))
    end
  end

  shared_examples 'they cannot manage other schools, groups and users' do
    it 'cannot manage school admin from another school' do
      expect(subject).not_to be_able_to(:manage, create(:school_admin, school: create(:school)))
    end

    it { is_expected.not_to be_able_to(:manage, create(:school_target, school: create(:school))) }
    it { is_expected.not_to be_able_to(:manage, Activity.new(school: create(:school))) }
    it { is_expected.not_to be_able_to(:download_school_data, create(:school)) }
    it { is_expected.not_to be_able_to(:show_management_dash, create(:school)) }
    it { is_expected.not_to be_able_to(:read_restricted_analysis, create(:school)) }
    it { is_expected.not_to be_able_to(:download_school_data, create(:school, school_group: school.school_group)) }
    it { is_expected.not_to be_able_to(:show_management_dash, create(:school_group))}
  end

  shared_examples 'they can manage correct types of tariffs' do |school_tariffs: false, group_tariffs: false, site_tariffs: false|
    it 'can manage school tariffs', if: school_tariffs do
      expect(subject).to be_able_to(:manage, school.energy_tariffs.build)
    end

    it 'cannot manage school tariffs', unless: school_tariffs do
      expect(subject).not_to be_able_to(:manage, school.energy_tariffs.build)
    end

    it 'can manage group tariffs', if: group_tariffs do
      expect(subject).to be_able_to(:manage, school.school_group.energy_tariffs.build)
    end

    it 'cannot manage group tariffs', unless: group_tariffs do
      expect(subject).not_to be_able_to(:manage, school.school_group.energy_tariffs.build)
    end

    it 'can manage site wide tariffs', if: site_tariffs do
      expect(subject).to be_able_to(:manage, SiteSettings.current.energy_tariffs.build)
    end

    it 'cannot manage site wide tariffs', unless: site_tariffs do
      expect(subject).not_to be_able_to(:manage, SiteSettings.current.energy_tariffs.build)
    end
  end

  shared_examples 'they can view school group but not manage it' do
    it { is_expected.to be_able_to(:compare, school_group) }
    it { is_expected.to be_able_to(:show_management_dash, school_group)}
    it { is_expected.not_to be_able_to(:update_settings, school_group)}
  end

  shared_examples 'they have group admin rights' do
    it { is_expected.to be_able_to(:compare, school_group) }
    it { is_expected.to be_able_to(:show_management_dash, school_group)}
    it { is_expected.to be_able_to(:update_settings, school_group)}

    it_behaves_like 'they can access the school dashboard and data' do
      let(:school) { create(:school, school_group: school_group) }
    end

    it_behaves_like 'they can manage correct types of tariffs', school_tariffs: true, group_tariffs: true, site_tariffs: false do
      let(:school) { create(:school, school_group: school_group) }
    end

    context 'with schools outside group' do
      it { is_expected.not_to be_able_to(:download_school_data, create(:school)) }
    end

    context 'with other public groups' do
      let(:other_school_group) { create(:school_group) }

      it { is_expected.to be_able_to(:compare, other_school_group) }
      it { is_expected.not_to be_able_to(:show_management_dash, other_school_group)}
    end

    context 'with other private groups' do
      let(:other_school_group) { create(:school_group, public: false) }

      it { is_expected.not_to be_able_to(:compare, other_school_group) }
      it { is_expected.not_to be_able_to(:show_management_dash, other_school_group)}
    end
  end

  shared_examples 'their access to other school dashboards is limited by data sharing settings' do |group_admin: false|
    let(:data_sharing) { :public }
    let(:other_school_in_group) { create(:school, school_group: user_group, data_sharing: data_sharing) }
    let(:school_in_different_group) { create(:school, :with_school_group, data_sharing: data_sharing) }

    context 'when data sharing is public' do
      context 'with school in their group' do
        it { is_expected.to be_able_to(:show, other_school_in_group) }
        it { is_expected.to be_able_to(:show_pupils_dash, other_school_in_group) }
      end

      context 'with school in different group' do
        it { is_expected.to be_able_to(:show, school_in_different_group) }
        it { is_expected.to be_able_to(:show_pupils_dash, school_in_different_group) }
      end
    end

    context 'when data sharing is within_group' do
      let(:data_sharing) { :within_group }

      context 'with school in their group' do
        it { is_expected.to be_able_to(:show, other_school_in_group) }
        it { is_expected.to be_able_to(:show_pupils_dash, other_school_in_group) }
      end

      context 'with school in different group' do
        it { is_expected.not_to be_able_to(:show, school_in_different_group) }
        it { is_expected.not_to be_able_to(:show_pupils_dash, school_in_different_group) }
      end
    end

    context 'when data sharing is private' do
      let(:data_sharing) { :private }

      context 'with school in their group', unless: group_admin do
        it { is_expected.not_to be_able_to(:show, other_school_in_group) }
        it { is_expected.not_to be_able_to(:show_pupils_dash, other_school_in_group) }
      end

      # Group admins can always see schools in their group
      context 'with school in their group', if: group_admin do
        it { is_expected.to be_able_to(:show, other_school_in_group) }
        it { is_expected.to be_able_to(:show_pupils_dash, other_school_in_group) }
      end

      context 'with school in different group' do
        it { is_expected.not_to be_able_to(:show, school_in_different_group) }
        it { is_expected.not_to be_able_to(:show_pupils_dash, school_in_different_group) }
      end
    end
  end

  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user)        { nil }

    context 'with a guest user' do
      let(:user) { create(:user, role: :guest) }

      it { is_expected.to be_able_to(:index, School) }

      # Can browse and view categories
      [ActivityCategory, InterventionTypeGroup].each do |model|
        [:index, :show, :recommended].freeze.each do |permission|
          it { is_expected.to be_able_to(permission, model.new) }
        end
      end

      [ActivityType, InterventionType].each do |model|
        [:index, :show, :search, :for_school].freeze.each do |permission|
          it { is_expected.to be_able_to(permission, model.new) }
        end
      end

      context 'with school groups' do
        it { is_expected.to be_able_to(:show, create(:school_group))}
        it { is_expected.not_to be_able_to(:show_management_dash, create(:school_group))}
        it { is_expected.not_to be_able_to(:update_settings, create(:school_group))}

        it { is_expected.to be_able_to(:compare, create(:school_group))}
        it { is_expected.not_to be_able_to(:compare, create(:school_group, public: false))}
      end

      context 'when accessing school dashboards' do
        let(:data_sharing) { :public }
        let(:school) { create(:school, data_sharing: data_sharing) }

        context 'when data sharing is public' do
          it { is_expected.to be_able_to(:show, school) }
          it { is_expected.to be_able_to(:show_pupils_dash, school) }
          it { is_expected.not_to be_able_to(:show_management_dash, school) }
          it { is_expected.not_to be_able_to(:read_restricted_analysis, school) }
          it { is_expected.not_to be_able_to(:download_school_data, school) }
        end

        context 'when data sharing is within_group' do
          let(:data_sharing) { :within_group }

          [:show, :show_pupils_dash, :show_management_dash, :read_restricted_advice, :read_restricted_analysis, :download_school_data].each do |permission|
            it { is_expected.not_to be_able_to(permission, school) }
          end
        end

        context 'when data sharing is private' do
          let(:data_sharing) { :private }

          [:show, :show_pupils_dash, :show_management_dash, :read_restricted_advice, :read_restricted_analysis, :download_school_data].each do |permission|
            it { is_expected.not_to be_able_to(permission, school) }
          end
        end

        it { is_expected.to be_able_to(:show, create(:school_target)) }

        it_behaves_like 'they can manage correct types of tariffs', school_tariffs: false, group_tariffs: false, site_tariffs: false do
          let(:school) { create(:school, :with_school_group) }
        end
      end
    end

    context 'when user is an admin' do
      let(:user) { create(:admin) }

      %w(Activity ActivityType ActivityCategory Calendar CalendarEvent School User SchoolTarget).each do |thing|
        it { is_expected.to be_able_to(:manage, thing.constantize.new) }
      end

      context 'with all schools' do
        [:show, :show_pupils_dash, :show_management_dash, :read_restricted_analysis].freeze.each do |permission|
          [true, false].freeze.each do |visibility|
            School.data_sharings.each_keys do |data_sharing|
              it { is_expected.to be_able_to(permission, create(:school, visible: visibility, data_sharing: data_sharing)) }
            end
          end
        end
      end

      context 'with all school groups' do
        [true, false].each do |public|
          it { is_expected.to be_able_to(:show_management_dash, create(:school_group, public: public))}
          it { is_expected.to be_able_to(:update_settings, create(:school_group, public: public))}
        end
      end

      it_behaves_like 'they can manage correct types of tariffs', school_tariffs: true, group_tariffs: true, site_tariffs: true do
        let(:school) { create(:school, :with_school_group) }
      end
    end

    context 'with school users' do
      let(:school) { create(:school, school_group: school_group, visible: visible) }
      let(:visible) { true }
      let(:school_group) { create(:school_group) }

      context 'when user is a school admin' do
        let(:user) { create(:school_admin, school: school) }

        it_behaves_like 'a user who cannot manage site wide content'

        context 'when school is visible' do
          it_behaves_like 'they can access the school dashboard and data'

          it_behaves_like 'they can record activities for their school'
          it_behaves_like 'they can set targets'
          it_behaves_like 'they can manage correct types of tariffs', school_tariffs: true

          it 'allows access to restricted analysis' do
            expect(ability).to be_able_to(:read_restricted_analysis, school)
            expect(ability).to be_able_to(:read_restricted_advice, school)
          end
        end

        context 'when school is not visible' do
          let(:visible) { false }

          it_behaves_like 'they cannot access the school dashboard and data'
        end


        it_behaves_like 'they cannot manage other schools, groups and users'
        it_behaves_like 'they can view school group but not manage it'

        it_behaves_like 'their access to other school dashboards is limited by data sharing settings' do
          let(:user_group) { school_group }
        end
      end

      context 'when user is a staff user' do
        let(:user) { create(:staff, school: school) }

        it_behaves_like 'a user who cannot manage site wide content'

        context 'when school is visible' do
          it_behaves_like 'they can access the school dashboard and data'
          it_behaves_like 'they can record activities for their school'
          it_behaves_like 'they can set targets'
          it_behaves_like 'they can manage correct types of tariffs', school_tariffs: false

          it 'allows access to restricted advice' do
            expect(ability).to be_able_to(:read_restricted_analysis, school)
            expect(ability).to be_able_to(:read_restricted_advice, school)
          end
        end

        context 'when school is not visible' do
          let(:visible) { false }

          it_behaves_like 'they cannot access the school dashboard and data'
        end

        it_behaves_like 'they cannot manage other schools, groups and users'

        it_behaves_like 'they can view school group but not manage it'

        it { is_expected.not_to be_able_to(:show_management_dash, create(:school_group))}

        it_behaves_like 'their access to other school dashboards is limited by data sharing settings' do
          let(:user_group) { school_group }
        end
      end

      context 'when user is a volunteer' do
        let(:user) { create(:volunteer, school: school) }

        it_behaves_like 'a user who cannot manage site wide content'

        context 'when school is visible' do
          it_behaves_like 'they can access the school dashboard and data'
          it_behaves_like 'they can record activities for their school'
          it_behaves_like 'they can set targets'
          it_behaves_like 'they can manage correct types of tariffs', school_tariffs: false

          it 'allows access to restricted advice' do
            expect(ability).to be_able_to(:read_restricted_analysis, school)
            expect(ability).to be_able_to(:read_restricted_advice, school)
          end
        end

        context 'when school is not visible' do
          let(:visible) { false }

          it_behaves_like 'they cannot access the school dashboard and data'
        end

        it_behaves_like 'they cannot manage other schools, groups and users'

        it_behaves_like 'they can view school group but not manage it'

        it { is_expected.not_to be_able_to(:show_management_dash, create(:school_group))}

        it_behaves_like 'their access to other school dashboards is limited by data sharing settings' do
          let(:user_group) { school_group }
        end
      end

      context 'with user is a pupil' do
        let(:user) { create(:pupil, school: school) }

        it_behaves_like 'a user who cannot manage site wide content'

        context 'when school is visible' do
          it_behaves_like 'they can access the school dashboard and data'
          it_behaves_like 'they can record activities for their school'

          it { is_expected.not_to be_able_to(:manage, create(:school_target, school: school)) }

          it_behaves_like 'they can manage correct types of tariffs', school_tariffs: false
        end

        context 'when school is not visible' do
          let(:visible) { false }

          it_behaves_like 'they cannot access the school dashboard and data'
        end

        it 'allows access to restricted advice' do
          expect(ability).to be_able_to(:read_restricted_analysis, school)
          expect(ability).to be_able_to(:read_restricted_advice, school)
        end

        it_behaves_like 'they can access the school dashboard and data'

        context 'when school does not have public data sharing' do
          let(:school) { create(:school, school_group: school_group, data_sharing: :within_group) }

          it 'restricts access to some analysis' do
            expect(ability).not_to be_able_to(:read_restricted_analysis, school)
            expect(ability).not_to be_able_to(:read_restricted_advice, school)
          end
        end

        context 'when school has public data' do
          let(:school) { create(:school, school_group: school_group, data_sharing: :public) }

          it 'restricts access to some analysis' do
            expect(ability).to be_able_to(:read_restricted_analysis, school)
            expect(ability).to be_able_to(:read_restricted_advice, school)
          end
        end

        it_behaves_like 'they cannot manage other schools, groups and users'

        it_behaves_like 'they can view school group but not manage it'
        it { is_expected.not_to be_able_to(:show_management_dash, create(:school_group))}

        it_behaves_like 'their access to other school dashboards is limited by data sharing settings' do
          let(:user_group) { school_group }
        end
      end
    end

    context 'when a group admin' do
      let(:user)                { create(:user, role: :group_admin, school_group: school_group)}
      let(:school_group)        { create(:school_group, public: is_public) }
      let(:is_public) { true }

      it_behaves_like 'their access to other school dashboards is limited by data sharing settings', group_admin: true do
        let(:user_group) { school_group }
      end

      context 'with a public group' do
        it_behaves_like 'they have group admin rights'
      end

      context 'with a private group' do
        let(:is_public) { false }

        it_behaves_like 'they have group admin rights'
      end

      context 'when completing onboarding' do
        context 'with an onboarding that has not started' do
          context 'when it is their group' do
            let(:school_onboarding) { create(:school_onboarding, school_group: school_group)}

            it { is_expected.to be_able_to(:manage, school_onboarding)}
          end

          context 'when it is not their group' do
            it { is_expected.not_to be_able_to(:manage, create(:school_onboarding, school_group: create(:school_group)))}
          end
        end

        context 'with an onboarding that has started' do
          let(:school_onboarding) { create(:school_onboarding, school_group: school_group, school: create(:school, school_group: school_group))}

          context 'with a school in their group' do
            it { is_expected.to be_able_to(:manage, school_onboarding)}
          end

          context 'with a school in another group' do
            let(:other_group) { create(:school_group) }
            let(:school_onboarding) { create(:school_onboarding, school_group: other_group, school: create(:school, school_group: other_group)) }

            it { is_expected.not_to be_able_to(:manage, school_onboarding) }
          end
        end
      end
    end
  end
end
