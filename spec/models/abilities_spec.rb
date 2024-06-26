require 'rails_helper'
require 'cancan/matchers'

shared_examples 'a user who cannot manage site wide content' do
  %w(ActivityType ActivityCategory SchoolTarget).each do |thing|
    it { is_expected.not_to be_able_to(:manage, thing.constantize.new) }
  end
end

shared_examples 'they can access the school dashboard and data' do
  %i[index show].each do |action|
    it { is_expected.to be_able_to(action, school) }
  end
  it { is_expected.to be_able_to(:download_school_data, school) }
end

shared_examples 'a user who can record activities for their school' do
  it { is_expected.to be_able_to(:manage, Activity.new(school: school)) }
  it { is_expected.to be_able_to(:read, ActivityCategory.new) }
  it { is_expected.to be_able_to(:show, ActivityType.new) }
end

shared_examples 'a user who can set targets' do
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

shared_examples 'a user who cannot manage other schools, groups and users' do
  it 'cannot manage school admin from another school' do
    expect(subject).not_to be_able_to(:manage, create(:school_admin, school: create(:school)))
  end

  it { is_expected.not_to be_able_to(:manage, create(:school_target, school: create(:school))) }
  it { is_expected.not_to be_able_to(:manage, Activity.new(school: create(:school))) }
  it { is_expected.not_to be_able_to(:download_school_data, create(:school)) }
  it { is_expected.not_to be_able_to(:download_school_data, create(:school, school_group: school.school_group)) }
  it { is_expected.not_to be_able_to(:show_management_dash, create(:school_group))}
end

shared_examples 'a user who can manage tariffs' do |school_tariffs: false, group_tariffs: false, site_tariffs: false|
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

shared_examples 'they can view and manage school group' do
  it { is_expected.to be_able_to(:compare, school_group) }
  it { is_expected.to be_able_to(:show_management_dash, school_group)}
  it { is_expected.to be_able_to(:update_settings, school_group)}
end

describe Ability do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }

    let(:user)        { nil }

    context 'when user is an admin' do
      let(:user) { create(:admin) }

      %w(Activity ActivityType ActivityCategory Calendar CalendarEvent School User SchoolTarget).each do |thing|
        it { is_expected.to be_able_to(:manage, thing.constantize.new) }
      end

      context 'with schools' do
        it { is_expected.to be_able_to(:show, create(:school, visible: false, public: false)) }
        it { is_expected.to be_able_to(:show, create(:school, visible: false, public: true)) }
        it { is_expected.to be_able_to(:show, create(:school, visible: true, public: false)) }
        it { is_expected.to be_able_to(:show, create(:school, visible: true, public: true)) }
      end

      context 'with school groups' do
        it { is_expected.to be_able_to(:show_management_dash, create(:school_group))}
        it { is_expected.to be_able_to(:update_settings, create(:school_group))}
      end

      it_behaves_like 'a user who can manage tariffs', school_tariffs: true, group_tariffs: true, site_tariffs: true do
        let(:school) { create(:school, :with_school_group) }
      end
    end

    context 'when user is a school admin' do
      let(:user) { create(:school_admin, school: school) }
      let(:school) { create(:school, school_group: school_group) }
      let(:school_group) { create(:school_group) }

      it_behaves_like 'a user who cannot manage site wide content'

      it_behaves_like 'they can access the school dashboard and data'
      it_behaves_like 'a user who can record activities for their school'
      it_behaves_like 'a user who can set targets'
      it_behaves_like 'a user who can manage tariffs', school_tariffs: true

      it_behaves_like 'a user who cannot manage other schools, groups and users'
      it_behaves_like 'they can view school group but not manage it'
    end

    context 'when user is a school staff user' do
      let(:school) { create(:school, school_group: school_group) }
      let(:school_group) { create(:school_group) }
      let(:user) { create(:staff, school: school) }

      it_behaves_like 'a user who cannot manage site wide content'
      it_behaves_like 'they can access the school dashboard and data'
      it_behaves_like 'a user who can record activities for their school'
      it_behaves_like 'a user who can set targets'
      it_behaves_like 'a user who can manage tariffs', school_tariffs: false

      it_behaves_like 'a user who cannot manage other schools, groups and users'

      it_behaves_like 'they can view school group but not manage it'

      it { is_expected.not_to be_able_to(:show_management_dash, create(:school_group))}
    end

    context 'when is a guest' do
      let(:school_group) { create(:school_group) }
      let(:school) { create(:school, school_group: school_group) }
      let(:user) { create(:user, role: :guest) }

      %i[index show].each do |action|
        it { is_expected.to be_able_to(action, school) }
      end

      it { is_expected.to be_able_to(:show, school) }
      it { is_expected.to be_able_to(:read, ActivityCategory.new) }
      it { is_expected.to be_able_to(:show, ActivityType.new) }
      it { is_expected.to be_able_to(:show, create(:school_target)) }

      it { is_expected.not_to be_able_to(:download_school_data, school) }
      it { is_expected.not_to be_able_to(:download_school_data, create(:school)) }
      it { is_expected.not_to be_able_to(:download_school_data, create(:school, school_group: school.school_group)) }
      it { is_expected.not_to be_able_to(:show_management_dash, create(:school_group))}
      it { is_expected.not_to be_able_to(:show_management_dash, school_group)}
      it { is_expected.not_to be_able_to(:update_settings, school_group)}

      it_behaves_like 'a user who can manage tariffs', school_tariffs: false, group_tariffs: false, site_tariffs: false do
        let(:school) { create(:school, :with_school_group) }
      end
    end

    context 'when a group admin' do
      let(:user)                { create(:user, role: :group_admin, school_group: school_group)}
      let(:school_group)        { create(:school_group, public: is_public) }
      let(:is_public) { true }

      context 'with a public group' do
        it_behaves_like 'they can view and manage school group'

        it_behaves_like 'they can access the school dashboard and data' do
          let(:school) { create(:school, school_group: school_group) }
        end
        it_behaves_like 'a user who can manage tariffs', school_tariffs: true, group_tariffs: true, site_tariffs: false do
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

      context 'with a private group' do
        let(:is_public) { false }

        it_behaves_like 'they can view and manage school group'

        it_behaves_like 'they can access the school dashboard and data' do
          let(:school) { create(:school, school_group: school_group) }
        end

        it_behaves_like 'a user who can manage tariffs', school_tariffs: true, group_tariffs: true, site_tariffs: false do
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
