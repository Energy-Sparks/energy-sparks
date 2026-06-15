require 'rails_helper'

describe 'School groups map page', :school_groups do
  shared_examples 'a group map page' do
    it 'displays the right breadcrumb' do
      expect(find('ol.main-breadcrumbs').all('li').collect(&:text)).to eq([I18n.t('common.schools'), school_group.name, I18n.t('school_groups.titles.map')])
    end

    it { expect(page).to have_css('div#geo-json-map') }
    it { expect(page).to have_title("#{school_group.name} #{I18n.t('school_groups.titles.map')}") }

    context 'when displaying schools' do
      it 'displays a summary of information' do
        expect(page).to have_link(school.name, href: school_path(school))
        expect(page).to have_content(I18n.t("common.school_types.#{school.school_type}"))
        expect(page).to have_content(school.address)
        expect(page).to have_content(school.postcode)
      end

      it 'displays fuel type icons' do
        expect(page).to have_css('i.fa-sun')
        expect(page).to have_css('i.fa-bolt')
        expect(page).to have_css('i.fa-fire')
        expect(page).to have_css('i.fa-fire-alt')
      end

      it 'groups the results' do
        expect(page).to have_css('#X-schools')
        expect(page).not_to have_css('li.page-item.letter.disabled', text: 'X')
        expect(page).to have_css('li.page-item.letter', text: 'X')
      end
    end
  end

  let!(:school_group) { create(:school_group, :with_active_schools, group_type: :general, public: true) }
  let!(:school) { create(:school, :with_fuel_configuration, name: 'Xavier school for gifted children', school_group: school_group) }

  before do
    visit map_school_group_path(school_group)
  end

  context 'with different group types' do
    context 'with general group' do
      it_behaves_like 'a group map page'
    end

    context 'with project group' do
      let!(:school) { create(:school, :with_fuel_configuration, :with_project, name: 'Xavier school for gifted children') }
      let!(:school_group) { school.project_groups.first }

      it_behaves_like 'a group map page'
    end

    context 'with a diocese' do
      let!(:school) { create(:school, :with_fuel_configuration, :with_diocese, name: 'Xavier school for gifted children') }
      let!(:school_group) { school.diocese }

      it_behaves_like 'a group map page'
    end
  end

  context 'when the group is private' do
    let!(:school_group) { create(:school_group, :with_active_schools, group_type: :general, public: false) }

    it 'still displays when not logged in' do
      expect(page).to have_title("#{school_group.name} #{I18n.t('school_groups.titles.map')}")
    end
  end

  context 'when displaying the group summary' do
    it 'displays expected message' do
      expect(page).to have_content('We are working with 2 schools in this group.')
    end

    context 'with local authority' do
      let!(:school_group) { create(:school_group, :with_active_schools, group_type: :local_authority, public: true) }

      it 'displays expected message' do
        expect(page).to have_content('We are working with 2 schools in this local authority.')
      end
    end

    context 'with partners' do
      let!(:school_group) { create(:school_group, :with_active_schools, :with_partners, group_type: :multi_academy_trust, public: true) }

      it 'displays expected message' do
        expect(page).to have_content("We are working with 2 schools in this multi-academy trust in partnership with #{school_group.partners.first.name}")
      end
    end
  end

  shared_examples 'a map page with an access restricted prompt' do
    it { expect(page).to have_content(I18n.t('school_groups.login_prompt.title', school_group: school_group.name)) }
    it { expect(page).to have_content('Please explore other school groups that are publicly available') }
  end

  shared_examples 'a map page with a login prompt' do
    it { expect(page).to have_content(I18n.t('school_groups.login_prompt.title', school_group: school_group.name)) }
    it { expect(page).to have_content(I18n.t('school_groups.login_prompt.login')) }
  end

  shared_examples 'a map page without a login or restricted prompt' do
    it { expect(page).not_to have_content(I18n.t('school_groups.login_prompt.title', school_group: school_group.name)) }
    it { expect(page).not_to have_content(I18n.t('school_groups.login_prompt.login')) }
    it { expect(page).not_to have_content('Please explore other school groups that are publicly available') }
  end

  shared_context 'when a group user signs in' do
    before do
      click_on 'Login'

      user = create(:group_admin, password: 'testingistesting', school_group:)

      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password

      within('#staff') { click_on 'Sign in' }
    end
  end

  describe 'Login prompt for private groups' do
    let!(:school_group) { }
    let!(:signed_in_user) {}

    before do
      sign_in signed_in_user if signed_in_user
    end

    context 'when visiting the map page' do
      before do
        visit map_school_group_path(school_group)
      end

      context 'when the group is private' do
        let!(:school_group) { create(:school_group, :with_active_schools, group_type: :general, public: false) }

        context 'when user is not signed in' do
          it_behaves_like 'a map page with a login prompt'

          context 'when user signs in as a group user for the same group' do
            include_context 'when a group user signs in'

            it 'redirects to group dashboard' do
              expect(page).to have_current_path(school_group_path(school_group), ignore_query: true)
            end
          end
        end

        context 'when user is already signed in as a user without access' do
          let(:signed_in_user) { create(:group_admin, school_group: create(:school_group)) }

          it_behaves_like 'a map page with an access restricted prompt'
        end

        context 'when user is already signed in as a group user for the same group' do
          let(:signed_in_user) { create(:group_admin, school_group:) }

          it_behaves_like 'a map page without a login or restricted prompt'
        end
      end

      context 'when group is not private' do
        let!(:school_group) { create(:school_group, :with_active_schools, group_type: :general, public: true) }

        it_behaves_like 'a map page without a login or restricted prompt'
      end
    end

    context 'when visiting a different school group page' do
      before do
        visit school_group_advice_path(school_group)
      end

      context 'when the group is private' do
        let!(:school_group) { create(:school_group, :with_active_schools, group_type: :general, public: false) }

        context 'when user is not signed in' do
          it_behaves_like 'a map page with a login prompt'

          context 'when user signs in as a group user' do
            include_context 'when a group user signs in'

            it 'redirects to original path' do
              expect(page).to have_current_path(school_group_advice_path(school_group), ignore_query: true)
            end
          end
        end

        context 'when user is signed in as a group user for the same group' do
          let(:signed_in_user) { create(:group_admin, school_group:) }

          it_behaves_like 'a map page without a login or restricted prompt'
        end
      end
    end
  end
end
