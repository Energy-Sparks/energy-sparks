RSpec.shared_examples 'an access controlled group page' do
  let(:expected_redirect) { "/school_groups/#{school_group.slug}/map" }
  let(:group_role) { :group_admin }

  context 'when the group is private' do
    before do
      school_group.update!(public: false)
      sign_in(user) if user
      visit path
    end

    context 'when not logged in' do
      let(:user) { nil }

      it 'has redirected' do
        expect(page).to have_current_path(expected_redirect, ignore_query: true)
      end
    end

    context 'when logged in as a school admin' do
      let(:user) { create(:school_admin, school: create(:school, school_group: school_group)) }

      it 'has not redirected' do
        expect(page).to have_current_path(path, ignore_query: true)
      end
    end

    context 'when logged in as the group admin' do
      let(:user) { create(group_role, school_group: school_group) }

      it 'has not redirected' do
        expect(page).to have_current_path(path, ignore_query: true)
      end
    end

    context 'when logged in as an admin' do
      let(:user) { create(:admin) }

      it 'has not redirected' do
        expect(page).to have_current_path(path, ignore_query: true)
      end
    end

    context 'when logged in as a school admin from a different group' do
      let(:user) { create(:school_admin, school: create(:school, :with_school_group)) }

      it 'has redirected' do
        expect(page).to have_current_path(expected_redirect, ignore_query: true)
      end
    end

    context 'when logged in as a different group admin' do
      let(:user) { create(:group_admin) }

      it 'has redirected' do
        expect(page).to have_current_path(expected_redirect, ignore_query: true)
      end
    end
  end

  context 'when the group is public but there are no active schools' do
    before do
      school_group.assigned_schools.update_all(active: false)
      sign_in(user) if user
      visit path
    end

    context 'when not logged in' do
      let(:user) { nil }

      it 'has redirected' do
        expect(page).to have_current_path(expected_redirect, ignore_query: true)
      end
    end

    context 'when logged in' do
      let(:user) { create(group_role, school_group: school_group) }

      it 'has redirected' do
        expect(page).to have_current_path(expected_redirect, ignore_query: true)
      end
    end
  end
end

RSpec.shared_examples 'a group page with schools filtered by permissions' do
  let(:user) { nil }
  let!(:filtered_school) { create(:school, :with_fuel_configuration, school_group:, data_sharing: :private) }

  before do
    sign_in(user) if user
    visit path
  end

  context 'when not signed in' do
    it 'does not show the school' do
      expect(page).to have_no_content(filtered_school.name)
    end
  end

  context 'when signed in as school admin' do
    let(:user) { create(:school_admin, school: create(:school, school_group:)) }

    it 'does not show the school' do
      expect(page).to have_no_content(filtered_school.name)
    end
  end

  context 'when signed in as the group admin' do
    let(:user) do
      if school_group.organisation?
        create(:group_admin, school_group:)
      else
        create(:group_manager, school_group:)
      end
    end

    it 'filters correctly' do
      if school_group.organisation?
        expect(page).to have_content(filtered_school.name)
      else
        expect(page).to have_no_content(filtered_school.name)
      end
    end
  end

  context 'when signed in as the group admin for a different group' do
    let(:user) { create(:group_admin, school_group: create(:school_group)) }

    it 'does not show the school' do
      expect(page).to have_no_content(filtered_school.name)
    end
  end

  context 'when signed in as an admin' do
    let(:user) { create(:admin) }

    it 'shows all the schools' do
      expect(page).to have_content(filtered_school.name)
    end
  end
end
