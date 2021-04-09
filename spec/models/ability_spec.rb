require 'rails_helper'
require 'cancan/matchers'

RSpec.describe 'abilities' do

  subject(:ability) { Ability.new(user) }
  let(:user) { nil }

  context 'with Schools' do
    let!(:school_group) { create(:school_group, name: 'School Group')}
    let!(:other_school) { create(:school, name: 'Other School', visible: true, school_group: school_group)}

    context 'that are not visible' do
      let!(:school)       { create(:school, name: 'School', visible: false, school_group: school_group)}

      it 'disallows guest access' do
        expect(ability).to_not be_able_to(:show, school)
        expect(ability).to_not be_able_to(:show_pupils_dash, school)
        expect(ability).to_not be_able_to(:show_teachers_dash, school)
        expect(ability).to_not be_able_to(:show_management_dash, school)
      end

      context "as school admin" do
        let!(:user)          { create(:school_admin, school: school) }

        it 'disallows access' do
          expect(ability).to_not be_able_to(:show, school)
          expect(ability).to_not be_able_to(:show_pupils_dash, school)
          expect(ability).to_not be_able_to(:show_teachers_dash, school)
          expect(ability).to_not be_able_to(:show_management_dash, school)
        end
      end

      context "as admin" do
        let(:user) { create(:admin) }

        it "can do anything" do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_teachers_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
        end
      end

    end

    context 'that are visible' do
      let!(:school)       { create(:school, name: 'School', visible: true, school_group: school_group)}

      it 'disallows guest access' do
        expect(ability).to be_able_to(:show, school)
        expect(ability).to be_able_to(:show_pupils_dash, school)
        #FIXME: this is allowed here, but in practice, guests cant do this
        #as the controller requires you to login
        expect(ability).to be_able_to(:show_teachers_dash, school)
        expect(ability).to_not be_able_to(:show_management_dash, school)
      end

      context "as school admin" do
        let!(:user)          { create(:school_admin, school: school) }

        it 'disallows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_teachers_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
        end
      end

      context "as related school admin" do
        let!(:user)          { create(:school_admin, school: other_school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          #at present this is allowed as any signed in user can see teacher dashboard
          expect(ability).to be_able_to(:show_teachers_dash, school)
          expect(ability).to_not be_able_to(:show_management_dash, school)
        end
      end

      context "as admin" do
        let(:user) { create(:admin) }

        it "can do anything" do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_teachers_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
        end
      end

    end

    context 'that are not public' do
      let!(:school)       { create(:school, name: 'School', visible: true, public: false, school_group: school_group)}

      it 'disallows guest access' do
        expect(ability).to_not be_able_to(:show, school)
        expect(ability).to_not be_able_to(:show_pupils_dash, school)
        expect(ability).to_not be_able_to(:show_teachers_dash, school)
        expect(ability).to_not be_able_to(:show_management_dash, school)
      end

      context "as school admin" do
        let!(:user)          { create(:school_admin, school: school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_teachers_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
        end
      end

      context "as related school admin" do
        let!(:user)          { create(:school_admin, school: other_school) }

        it 'allows access' do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_teachers_dash, school)
          expect(ability).to_not be_able_to(:show_management_dash, school)
        end
      end

      context "as admin" do
        let(:user) { create(:admin) }

        it "can do anything" do
          expect(ability).to be_able_to(:show, school)
          expect(ability).to be_able_to(:show_pupils_dash, school)
          expect(ability).to be_able_to(:show_teachers_dash, school)
          expect(ability).to be_able_to(:show_management_dash, school)
        end
      end

    end


  end


end
