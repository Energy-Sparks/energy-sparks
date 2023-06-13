require 'rails_helper'
require "cancan/matchers"

describe Ability do

  describe 'abilities' do
    subject(:ability) { Ability.new(user) }
    let(:user)        { nil }

    context "when is an admin" do
      let(:user) { create(:admin) }

      %w(Activity ActivityType ActivityCategory Calendar CalendarEvent School User SchoolTarget).each do |thing|
        it { is_expected.to be_able_to(:manage, thing.constantize.new) }
      end

      it { is_expected.to be_able_to(:show, create(:school, visible: false, public: true)) }
      it { is_expected.to be_able_to(:show, create(:school, visible: true, public: true)) }
      it { is_expected.to be_able_to(:show, create(:school, visible: false, public: true)) }
      it { is_expected.to be_able_to(:show, create(:school, visible: false, public: false)) }

      it { is_expected.to be_able_to(:show_management_dash, create(:school_group))}
      it { is_expected.to be_able_to(:update_settings, create(:school_group))}
    end

    context "as a school admin" do
      let(:mygroup) { create(:school_group) }
      let(:school) { create(:school, school_group: mygroup) }
      let(:another_school) { create(:school) }
      let(:user) { create(:school_admin, school: school) }

      let(:other_admin) { create(:school_admin, school: school) }
      let(:cluster_admin) { create(:school_admin, cluster_schools: [school]) }


      %i[index show usage suggest_activity].each do |action|
        it{ is_expected.to be_able_to(action, school) }
      end

      %w(ActivityType ActivityCategory SchoolTarget).each do |thing|
        it { is_expected.to_not be_able_to(:manage, thing.constantize.new) }
      end

      it { is_expected.to be_able_to(:manage, create(:school_target, school: school)) }
      it { is_expected.to_not be_able_to(:manage, create(:school_target, school: another_school)) }

      it { is_expected.to be_able_to(:manage, Activity.new(school: school)) }
      it { is_expected.not_to be_able_to(:manage, Activity.new(school: another_school)) }
      it { is_expected.to be_able_to(:read, ActivityCategory.new) }
      it { is_expected.to be_able_to(:show, ActivityType.new) }
      it { is_expected.not_to be_able_to(:update_settings, mygroup)}

      it "can manage another school admin for this school" do
        expect(subject).to be_able_to(:manage, other_admin)
      end

      it "cannot manage another school admin" do
        expect(subject).to_not be_able_to(:manage, create(:school_admin, school: another_school))
      end

      it "can manage cluster admin for this school" do
        expect(subject).to be_able_to(:manage, cluster_admin)
      end

      it { is_expected.to be_able_to(:download_school_data, school) }
      it { is_expected.to_not be_able_to(:download_school_data, another_school) }
      it { is_expected.to_not be_able_to(:download_school_data, create(:school, school_group: school.school_group)) }

      it { is_expected.to be_able_to(:show_management_dash, mygroup)}
      it { is_expected.to_not be_able_to(:show_management_dash, create(:school_group))}
    end

    context "when is a school user" do
      let(:mygroup) { create(:school_group) }
      let(:school) { create(:school, school_group: mygroup) }
      let(:another_school) { create(:school) }
      let(:user) { create(:staff, school: school) }

      %w(ActivityType ActivityCategory Calendar CalendarEvent School User).each do |thing|
        it { is_expected.not_to be_able_to(:manage, thing.constantize.new) }
      end

      %i[index show usage suggest_activity].each do |action|
        it{ is_expected.to be_able_to(action, school) }
      end

      it { is_expected.to be_able_to(:manage, create(:school_target, school: school)) }
      it { is_expected.to_not be_able_to(:manage, create(:school_target, school: another_school)) }

      it { is_expected.to be_able_to(:manage, Activity.new(school: school)) }
      it { is_expected.not_to be_able_to(:manage, Activity.new(school: another_school)) }
      it { is_expected.to be_able_to(:read, ActivityCategory.new) }
      it { is_expected.to be_able_to(:show, ActivityType.new) }

      it { is_expected.to be_able_to(:download_school_data, school) }
      it { is_expected.to_not be_able_to(:download_school_data, another_school) }
      it { is_expected.to_not be_able_to(:download_school_data, create(:school, school_group: school.school_group)) }

      it { is_expected.to be_able_to(:show_management_dash, mygroup)}
      it { is_expected.to_not be_able_to(:show_management_dash, create(:school_group))}
      it { is_expected.not_to be_able_to(:update_settings, mygroup)}
    end

    context "when is a guest" do
      let(:mygroup) { create(:school_group) }
      let(:school) { create(:school, school_group: mygroup) }
      let(:user) { create(:user, role: :guest) }

      %i[index show usage].each do |action|
        it { is_expected.to be_able_to(action, school) }
      end

      it { is_expected.to be_able_to(:suggest_activity, school) }
      it { is_expected.to be_able_to(:show, school) }
      it { is_expected.to be_able_to(:read, ActivityCategory.new) }
      it { is_expected.to be_able_to(:show, ActivityType.new) }
      it { is_expected.to be_able_to(:show, create(:school_target) ) }
      it { is_expected.to_not be_able_to(:download_school_data, school) }
      it { is_expected.to_not be_able_to(:download_school_data, create(:school)) }
      it { is_expected.to_not be_able_to(:download_school_data, create(:school, school_group: school.school_group)) }

      it { is_expected.to_not be_able_to(:show_management_dash, create(:school_group))}
      it { is_expected.to_not be_able_to(:show_management_dash, mygroup)}
      it { is_expected.to_not be_able_to(:update_settings, mygroup)}
    end

    context "when a group admin" do
      let(:public)              { true }
      let(:school_group)        { create(:school_group, public: public) }
      let(:school)              { create(:school, school_group: school_group) }
      let(:user)                { create(:user, role: :group_admin, school_group: school_group)}
      it { is_expected.to be_able_to(:compare, school_group) }

      context 'and group is private' do
        let(:public)     { false }
        it { is_expected.to be_able_to(:compare, school_group) }

        context 'and its not my group' do
          let(:my_group)  { create(:school_group) }

          let(:user)    {  create(:user, role: :group_admin, school_group: my_group) }
          it { is_expected.to be_able_to(:compare, my_group) }
          it { is_expected.to_not be_able_to(:compare, school_group) }

          it { is_expected.to be_able_to(:show_management_dash, my_group)}
          it { is_expected.not_to be_able_to(:show_management_dash, school_group)}
        end
      end

      it { is_expected.to be_able_to(:download_school_data, school) }
      it { is_expected.to_not be_able_to(:download_school_data, create(:school)) }
      it { is_expected.to be_able_to(:download_school_data, create(:school, school_group: school.school_group)) }

      it { is_expected.to be_able_to(:show_management_dash, school_group)}
      it { is_expected.to_not be_able_to(:show_management_dash, create(:school_group))}
      it { is_expected.to be_able_to(:update_settings, school_group)}

      context 'is onboarding' do

        context 'a school in their group' do
          let(:school_onboarding)   { create(:school_onboarding, school_group: school_group)}
          it { is_expected.to be_able_to(:manage, school_onboarding)}
        end

        context 'but not for their group' do
          let(:school_onboarding)   { create(:school_onboarding, school_group: create(:school_group)) }
          it { is_expected.to_not be_able_to(:manage, school_onboarding)}
        end

        context 'for a different school' do
          let(:school_onboarding)  { create(:school_onboarding, school: create(:school) ) }
          it { is_expected.to_not be_able_to(:manage, school_onboarding) }
        end

      end
    end
  end
end
