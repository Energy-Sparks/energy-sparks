require 'rails_helper'
require "cancan/matchers"

describe User do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }
    let(:user)        { nil }

    context "when is an admin" do
      let(:user) { create(:user, role: :admin) }

      %w(Activity ActivityType ActivityCategory Calendar CalendarEvent School User).each do |thing|
        it { is_expected.to be_able_to(:manage, thing.constantize.new) }
      end
    end

    context "when is a school user" do
      let(:school) { create(:school) }
      let(:another_school) { create(:school) }
      let(:user) { create(:user, role: :school_user, school: school) }

      %w(ActivityType ActivityCategory Calendar CalendarEvent School User).each do |thing|
        it { is_expected.not_to be_able_to(:manage, thing.constantize.new) }
      end

      %i[index show usage awards scoreboard suggest_activity].each do |action|
        it{ is_expected.to be_able_to(action, School.new) }
      end

      it { is_expected.to be_able_to(:manage, Activity.new(school: school)) }
      it { is_expected.not_to be_able_to(:manage, Activity.new(school: another_school)) }
      it { is_expected.to be_able_to(:read, ActivityCategory.new) }
      it { is_expected.to be_able_to(:show, ActivityType.new) }
    end

    context "when is a guest" do
      let(:user) { create(:user, role: :guest) }

      %i[index show usage awards scoreboard].each do |action|
        it { is_expected.to be_able_to(action, School.new) }
      end

      it { is_expected.not_to be_able_to(:suggest_activity, School.new) }
      it { is_expected.to be_able_to(:show, Activity.new) }
      it { is_expected.to be_able_to(:read, ActivityCategory.new) }
      it { is_expected.to be_able_to(:show, ActivityType.new) }

    end
  end
end


