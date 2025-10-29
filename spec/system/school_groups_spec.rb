require 'rails_helper'

describe 'school groups', :school_groups, type: :system do
  let!(:school_group) { create(:school_group, public: public, default_issues_admin_user: nil, default_template_calendar: create(:template_calendar, :with_previous_and_next_academic_years)) }
  let(:public) { true }

  let!(:user)                  { create(:user) }

  let!(:school_1)              { create(:school, school_group: school_group, number_of_pupils: 10, floor_area: 200.0) }
  let!(:school_2)              { create(:school, school_group: school_group, number_of_pupils: 20, floor_area: 300.0) }

  before do
    allow_any_instance_of(SchoolGroup).to receive(:fuel_types).and_return([:electricity, :gas, :storage_heaters])
    DashboardMessage.create!(messageable_type: 'SchoolGroup', messageable_id: school_group.id, message: 'A school group notice message')
    school_group.schools.reload
  end

  context 'when not logged in' do
    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'schools are filtered by permissions'
    end

    context 'with a public school group with no active schools' do
      before do
        school_group.schools.update_all(active: false)
        visit school_group_path(school_group)
      end

      it 'has redirected' do
        expect(page).to have_current_path("/school_groups/#{school_group.slug}/map", ignore_query: true)
      end
    end

    context 'with a private school group' do
      let(:public) { false }

      before do
        visit school_group_path(school_group)
      end

      it 'has redirected' do
        expect(page).to have_current_path("/school_groups/#{school_group.slug}/map", ignore_query: true)
      end
    end
  end

  context 'when logged in as a school admin' do
    let!(:user) { create(:school_admin, school: school_1) }

    before do
      sign_in(user)
    end

    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'schools are filtered by permissions', school_admin: true
    end

    context 'with a private school group' do
      let(:public) { false }

      it_behaves_like 'schools are filtered by permissions', school_admin: true
    end
  end

  context 'when logged in as a non school admin' do
    before do
      sign_in(user)
    end

    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'schools are filtered by permissions'
    end

    context 'with a private school group' do
      let(:public) { false }

      it 'has redirected' do
        visit school_group_path(school_group)
        expect(page).to have_current_path("/school_groups/#{school_group.slug}/map", ignore_query: true)
      end
    end
  end

  context 'when logged in as the group admin' do
    let!(:user)           { create(:group_admin, school_group: school_group) }
    let!(:school_group2)  { create(:school_group, default_issues_admin_user: nil) }

    before do
      sign_in(user)
    end

    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'schools are filtered by permissions', admin: true
    end

    context 'with a private school group' do
      let(:public) { false }

      it_behaves_like 'schools are filtered by permissions', admin: true
    end
  end

  context 'when logged in as an admin' do
    let!(:user)           { create(:admin) }

    before do
      sign_in(user)
    end

    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'schools are filtered by permissions', admin: true
    end

    context 'with a private school group' do
      let(:public) { false }

      it_behaves_like 'schools are filtered by permissions', admin: true
    end

    context 'when there are archived schools' do
      before do
        school_group.schools.first.update(active: false)
      end

      it 'doesnt show those schools' do
        visit school_group_path(school_group)
        expect(page).not_to have_content(school_group.schools.first.name)
      end
    end
  end

  context 'when logged in as a group admin for a different group' do
    let!(:user) { create(:group_admin, school_group: create(:school_group, default_issues_admin_user: nil)) }

    before do
      sign_in(user)
    end

    context 'with a public school group' do
      let(:public) { true }

      it_behaves_like 'schools are filtered by permissions', admin: false
    end

    context 'with a private school group' do
      let(:public) { false }

      it 'has redirected' do
        visit school_group_path(school_group)
        expect(page).to have_current_path("/school_groups/#{school_group.slug}/map", ignore_query: true)
      end
    end
  end
end
