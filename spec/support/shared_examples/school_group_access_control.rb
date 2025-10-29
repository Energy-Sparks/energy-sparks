RSpec.shared_examples 'an access controlled group page' do
  let(:expected_redirect) { "/school_groups/#{school_group.slug}/map" }

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
      let(:user) { create(:group_admin, school_group: school_group) }

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
      school_group.schools.update_all(active: false)
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
      let(:user) { create(:group_admin, school_group: school_group) }

      it 'has redirected' do
        expect(page).to have_current_path(expected_redirect, ignore_query: true)
      end
    end
  end
end

RSpec.shared_examples 'a group page with schools filtered by permissions' do
  let(:user) { nil }

  context 'with a public group' do
    before do
      school_group.update!(public: true)
      sign_in(user) if user
      visit path
    end

    context 'when not signed in' do
      it_behaves_like 'data sharing options are applied'
    end

    context 'when signed in as school admin' do
      let(:user) { create(:school_admin, school: create(:school, school_group:)) }

      it_behaves_like 'data sharing options are applied', school_admin: true
    end

    context 'when signed in as the group admin' do
      let(:user) { create(:group_admin, school_group:) }

      it_behaves_like 'data sharing options are applied', group_admin: true
    end

    context 'when signed in as the group admin for a different group' do
      let(:user) { create(:group_admin, school_group: create(:school_group)) }

      it_behaves_like 'data sharing options are applied'
    end

    context 'when signed in as an admin' do
      let(:user) { create(:admin) }

      it_behaves_like 'data sharing options are applied', admin: true
    end
  end

  context 'with a private group' do
    before do
      school_group.update!(public: false)
      sign_in(user) if user
      visit path
    end

    context 'when signed in as school admin' do
      let(:user) { create(:school_admin, school: create(:school, school_group:)) }

      it_behaves_like 'data sharing options are applied', school_admin: true
    end

    context 'when signed in as the group admin' do
      let(:user) { create(:group_admin, school_group:) }

      it_behaves_like 'data sharing options are applied', group_admin: true
    end

    context 'when signed in as an admin' do
      let(:user) { create(:admin) }

      it_behaves_like 'data sharing options are applied', admin: true
    end
  end
end

RSpec.shared_examples 'data sharing options are applied' do |admin: false, group_admin: false, school_admin: false|
  let(:data_sharing) { :within_group }
  let!(:filtered_school) { create(:school, school_group: school_group, data_sharing: data_sharing) }

  before do
    visit school_group_path(school_group)
  end

  context 'with data sharing set to within_group' do
    it 'does not show the school', unless: admin || school_admin || group_admin do
      expect(page).to have_no_content(filtered_school.name)
    end

    it 'shows all the schools', if: admin || school_admin || group_admin do
      expect(page).to have_content(filtered_school.name)
    end
  end

  context 'with data sharing set to private' do
    let(:data_sharing) { :private }

    it 'does not show the school', unless: admin || group_admin do
      expect(page).to have_no_content(filtered_school.name)
    end

    it 'shows all the schools', if: admin || group_admin do
      expect(page).to have_content(filtered_school.name)
    end
  end
end
