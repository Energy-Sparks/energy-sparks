# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Navigation -> second nav' do
  let!(:user) {}
  let(:school_group) { create(:school_group) }
  let(:data_enabled) { true }
  let(:school) { create(:school, school_group:, data_enabled: data_enabled) }
  let(:school_with_points) { create(:school, :with_points, scoreboard: create(:scoreboard)) }
  let(:nav) { page.find(:css, 'nav.navbar-second') }

  before do
    sign_in(user) if user
  end

  shared_examples 'a back to dashboard link' do |display: true|
    it 'shows back to dashboard link', if: display do
      expect(nav).to have_link('Back to dashboard', href: school_path(school))
    end

    it 'does not back to dashboard link', unless: display do
      expect(nav).not_to have_link('Back to dashboard', href: school_path(school))
    end
  end

  shared_examples 'a school name and dashboard link' do |display: true|
    it 'shows school name and dashboard link', if: display do
      expect(nav).to have_link(school.name, href: school_path(school))
    end

    it 'does not school name and dashboard link', unless: display do
      expect(nav).not_to have_link(school.name, href: school_path(school))
    end
  end

  shared_examples 'a group name and group dashboard link' do |display: true|
    it 'shows school group name and group dashboard link', if: display do
      expect(nav).to have_link(school_group.name, href: school_group_path(school_group))
    end

    it 'does not show school group name and group dashboard link', unless: display do
      expect(nav).not_to have_link(school_group.name, href: school_group_path(school_group))
    end
  end

  shared_examples 'second nav without a left link' do
    it_behaves_like 'a school name and dashboard link', display: false
    it_behaves_like 'a back to dashboard link', display: false
    it_behaves_like 'a group name and group dashboard link', display: false
  end

  describe 'Second nav left link' do
    context 'when user is not logged in' do
      context 'when on a page with school context' do
        before { visit school_path(school) }

        it_behaves_like 'a school name and dashboard link'
      end

      context 'when on a page with non school or school group context' do
        before { visit home_page_path }

        it_behaves_like 'second nav without a left link'
      end

      context 'when on a school group page' do
        before { visit school_group_path(school_group) }

        it_behaves_like 'a group name and group dashboard link'
      end
    end

    context 'when current user is a school admin' do
      let(:user) { create(:school_admin, school:) }

      context 'when on a page with school context' do
        before { visit school_path(school) }

        it_behaves_like 'a school name and dashboard link'
      end

      context 'when on a page with non school or school group context' do
        before { visit home_page_path }

        it_behaves_like 'a back to dashboard link'
      end

      context 'when on a school group page' do
        before { visit school_group_path(school_group) }

        it_behaves_like 'a back to dashboard link'
      end
    end

    context 'when current user is a school group admin' do
      let(:user) { create(:group_admin, school_group:) }

      context 'when on a page with school context' do
        before { visit school_path(school) }

        it_behaves_like 'a school name and dashboard link'
      end

      context 'when on a school group page' do
        before { visit school_group_path(school_group) }

        it_behaves_like 'a group name and group dashboard link'
      end

      context 'when on a page with non school or school group context' do
        before { visit home_page_path }

        it_behaves_like 'second nav without a left link'
      end
    end
  end

  describe 'Mini podium' do
    context 'when on a page with a school context' do
      context 'when school has points' do
        before { visit school_path(school_with_points) }

        it 'shows mini podium with link to scoreboard' do
          expect(nav).to have_css('#mini-podium')
          expect(nav).to have_link '1 points 1st'
        end
      end

      context 'when school does not have points' do
        before { visit school_path(school) }

        it { expect(nav).to have_no_css('#mini-podium') }
      end
    end

    context 'when on a page with a non-school context' do
      before { visit home_page_path }

      it { expect(nav).to have_no_css('#mini-podium') }
    end
  end

  describe 'School status buttons' do
    context 'when on a school page' do
      before { visit school_path(school) }

      context 'when logged in as a non admin' do
        let(:user) { create(:pupil) }

        it { expect(nav).to have_css('#school-status-buttons') }

        it 'does not display buttons' do
          expect(nav).to have_no_link('Visible')
          expect(nav).to have_no_link('Public')
          expect(nav).to have_no_link('Process data')
          expect(nav).to have_no_link('Data visible')
          expect(nav).to have_no_css('a i.fa-arrows-rotate')
        end
      end

      context 'when logged in as an admin' do
        let(:user) { create(:admin) }

        it { expect(nav).to have_css('#school-status-buttons') }

        it 'displays buttons' do
          expect(nav).to have_link('Visible')
          expect(nav).to have_link('Public')
          expect(nav).to have_link('Process data')
          expect(nav).to have_link('Data visible')
          expect(nav).to have_css('a i.fa-arrows-rotate')
        end
      end
    end
  end

  describe 'Alternative dashboard link' do
    context 'when on adult dashboard' do
      before { visit school_path(school) }

      it 'has a link to pupil dashboard' do
        expect(nav).to have_link('Pupil dashboard', href: pupils_school_path(school))
      end
    end

    context 'when on pupil dashboard' do
      before { visit pupils_school_path(school) }

      it 'has a link to adult dashboard' do
        expect(nav).to have_link('Adult dashboard', href: school_path(school))
      end
    end

    context 'when on a non dashboard page with school context' do
      before { visit school_advice_path(school) }

      it 'has a link to pupil dashboard' do
        expect(nav).to have_link('Pupil dashboard', href: pupils_school_path(school))
      end

      it 'has a link to adult dashboard' do
        expect(nav).to have_link('Adult dashboard', href: school_path(school))
      end
    end
  end

  describe 'Enrol link' do
    before { visit home_page_path }

    context 'when user not signed in' do
      let(:user) {}

      it { expect(nav).to have_link 'Enrol' }
    end

    context 'when user signed in' do
      let(:user) { create(:pupil) }

      it { expect(nav).to have_no_link 'Enrol' }
    end
  end

  describe 'Manage school group menu' do
    let(:path) { school_group_path(school.school_group) }
    let(:manage_school_group_menu) { nav.find_by(id: 'manage-school-group-menu') }

    context 'when on a non school group page' do
      let(:path) { visit home_page_path }

      it_behaves_like 'a page without a manage school group menu'
    end

    context 'when on a school group page' do
      let(:path) { school_group_path(school.school_group) }

      context 'when user is a site admin' do
        before { Flipper.enable(:school_group_secr_report) }

        let(:user) { create(:admin) }

        it_behaves_like 'a page with a manage school group menu'
        it_behaves_like 'a page with a manage school group menu including admin links'
      end

      context 'when user is a school group admin for different school' do
        let(:user) { create(:group_admin, school_group: create(:school_group)) }

        it_behaves_like 'a page without a manage school group menu'
      end

      context 'when user is a school group admin for own school' do
        let(:user) { create(:group_admin, school_group: school_group) }

        it_behaves_like 'a page with a manage school group menu'
        it_behaves_like 'a page with a manage school group menu not including admin links'

        it_behaves_like 'a page with a manage school group menu' do
          let(:path) { map_school_group_path(school_group) }
        end
        it_behaves_like 'a page with a manage school group menu' do
          let(:path) { comparisons_school_group_path(school_group) }
        end
        it_behaves_like 'a page with a manage school group menu' do
          let(:path) { priority_actions_school_group_path(school_group) }
        end
        it_behaves_like 'a page with a manage school group menu' do
          let(:path) { current_scores_school_group_path(school_group) }
        end
      end

      context 'when user is not a school group admin' do
        let(:path) { school_group_path(school.school_group) }

        it_behaves_like 'a page without a manage school group menu'
      end
    end
  end

  describe 'Manage school menu' do
    context 'when on a non school page' do
      before { visit home_page_path }

      it { expect(nav).to have_no_css('#manage-school-menu') }
    end

    context 'when on a school page' do
      before { visit school_path(school) }

      context 'when user is a school admin for school' do
        let(:user) { create(:school_admin, school:) }

        it { expect(nav).to have_css('#manage-school-menu') }
      end

      context 'when user is a school admin for a different school' do
        let(:user) { create(:school_admin, school: create(:school)) }

        it { expect(nav).to have_no_css('#manage-school-menu') }
      end

      context 'when user is logged out' do
        let(:user) {}

        it { expect(nav).to have_no_css('#manage-school-menu') }
      end
    end

    ## NB: contents of this menu is checked in system/schools/dashboard/manage_school_spec.rb
  end

  describe 'My school group menu' do
    before { visit home_page_path }

    context 'when logged out' do
      let(:user) {}

      it { expect(nav).to have_no_css('#my-school-group-menu') }
    end

    context 'when user is a group admin for school group' do
      let(:user) { create(:group_admin, school_group:) }

      it 'links to group dashboard' do
        expect(nav).to have_link('Group dashboard', href: school_group_path(school_group))
      end

      context 'when school group has no schools' do
        it { expect(nav).to have_css('#my-school-group-menu') }
        it { expect(nav).to have_no_css('#my-school-group-menu div.dropdown-divider') }
      end

      context 'when school group has schools' do
        let(:school_group) { create(:school_group, :with_active_schools) }

        it { expect(nav).to have_css('#my-school-group-menu') }
        it { expect(nav).to have_css('#my-school-group-menu div.dropdown-divider') }

        it 'links to schools' do
          expect(nav).to have_link(school_group.schools.first.name)
        end
      end
    end

    context 'when user has a school group but insufficient permissions' do
      let(:user) { create(:pupil, school_group:) }

      it { expect(nav).to have_no_css('#my-school-group-menu') }
    end
  end

  describe 'My school menu' do
    before { visit home_page_path }

    context 'when logged out' do
      let(:user) {}

      it { expect(nav).to have_no_css('#my-school-menu') }
    end

    context 'when admin' do
      let(:user) { create(:admin, school:) }

      it { expect(nav).to have_no_css('#my-school-menu') }
    end

    %i[pupil school_admin staff pupil].each do |user_type|
      let(:user) { create(user_type, school:) }

      it "displays the menu for #{user_type}" do
        expect(page).to have_css('#my-school-menu')
      end
    end

    context 'when user is non-admin' do
      let(:data_enabled) { }
      let(:fuel_configuration) { {} }
      let(:school_school_group) {}
      let(:school) { create(:school, :with_fuel_configuration, **fuel_configuration, data_enabled: data_enabled, school_group: school_school_group, scoreboard: create(:scoreboard)) }
      let(:user_school_group) {}
      let(:user) { create(:staff, school: school, school_group: user_school_group) }

      it 'has standard links' do
        within '#my-school-menu' do
          expect(page).to have_link(school.name)
          expect(page).to have_link('Recommended activities', href: school_recommendations_path(school))
          expect(page).to have_link('School programmes', href: programme_types_path)
          expect(page).to have_link('Scoreboard')
          expect(page).to have_link('My alerts')
        end
      end

      describe 'school group link' do
        context 'with school group' do
          let(:user_school_group) { create(:school_group) }

          it { expect(page).to have_link('My school group') }
        end

        context 'without school group' do
          let(:user_school_group) { }

          it { expect(page).not_to have_link('My school group') }
        end
      end

      describe 'compare schools link' do
        context 'when users school is in school group' do
          let(:school_school_group) { create(:school_group) }

          it 'has compare school link' do
            within '#my-school-menu' do
              expect(page).to have_link('Compare schools')
            end
          end
        end

        context 'when users school is not in school group' do
          let(:school_school_group) { }

          it 'does not have compare school link' do
            within '#my-school-menu' do
              expect(page).not_to have_link('Compare schools')
            end
          end
        end
      end

      describe 'data enabled items' do
        context 'when data enabled' do
          let(:data_enabled) { true }

          it 'has standard links' do
            within '#my-school-menu' do
              expect(page).to have_link('Energy analysis')
              expect(page).to have_link('Review targets')
              expect(page).to have_link('Download our data')
            end
          end

          context 'when school has solar and electricity' do
            let(:fuel_configuration) { { has_electricity: true, has_solar_pv: true } }

            it { expect(page).to have_link('Electricity and solar usage') }
            it { expect(page).not_to have_link('Electricity usage') }
          end

          context 'when school has electricity and no solar' do
            let(:fuel_configuration) { { has_electricity: true, has_solar_pv: false } }

            it { expect(page).not_to have_link('Electricity and solar usage') }
            it { expect(page).to have_link('Electricity usage') }
          end

          context 'when school has gas and storage' do
            let(:fuel_configuration) { { has_gas: true, has_storage_heaters: true } }

            it 'has gas and storage heater links' do
              expect(page).to have_link('Gas usage')
              expect(page).to have_link('Storage heater usage')
            end
          end

          context 'when school has no fuel types' do
            let(:fuel_configuration) { { has_electricity: false, has_solar_pv: false, has_gas: false, has_storage_heaters: false } }

            it 'has no fuel links' do
              expect(page).not_to have_link('Electricity and solar usage')
              expect(page).not_to have_link('Electricity usage')
              expect(page).not_to have_link('Gas usage')
              expect(page).not_to have_link('Storage heater usage')
            end
          end
        end

        context 'when not data enabled' do
          let(:fuel_configuration) { { has_electricity: true, has_solar_pv: true, has_gas: true, has_storage_heaters: true } }
          let(:data_enabled) { false }

          it { expect(page).not_to have_link('Energy analysis') }
          it { expect(page).not_to have_link('Download our data') }

          it 'has no fuel links' do
            expect(page).not_to have_link('Electricity and solar usage')
            expect(page).not_to have_link('Electricity usage')
            expect(page).not_to have_link('Gas usage')
            expect(page).not_to have_link('Storage heater usage')
          end
        end
      end
    end
  end

  describe 'My schools menu (switch schools)' do
    before { visit home_page_path }

    context 'when logged out' do
      let(:user) {}

      it { expect(nav).to have_no_css('#my-schools-menu') }
    end

    context 'when user is a school admin for school' do
      let(:user) { create(:school_admin, school:) }

      context 'when school has no cluster schools' do
        it { expect(nav).to have_no_css('#my-schools-menu') }
      end

      context 'when school has cluster schools' do
        let(:user) { create(:school_admin, :with_cluster_schools) }

        it { expect(nav).to have_css('#my-schools-menu') }

        it 'links to schools' do
          expect(nav).to have_link(user.school.name)
          expect(nav).to have_link(user.cluster_schools.first.name)
        end
      end
    end
  end

  describe 'Sign In link' do
    before { visit home_page_path }

    context 'when user signed out' do
      let(:user) {}

      it { expect(nav).to have_link 'Sign In' }
    end

    context 'when user signed in' do
      let(:user) { create(:pupil) }

      it { expect(nav).to have_no_link 'Sign In' }
    end
  end

  describe 'Sign Out link' do
    before { visit home_page_path }

    context 'when user signed in' do
      let(:user) { create(:pupil) }

      it { expect(nav).to have_link 'Sign Out' }
    end

    context 'when user signed out' do
      let(:user) {}

      it { expect(nav).to have_no_link 'Sign Out' }
    end
  end

  context 'with profile feature', with_feature: :profile_pages do
    describe 'My Profile link' do
      before { visit home_page_path }

      context 'when school user signed in' do
        let(:user) { create(:school_admin) }

        it { expect(nav).to have_link(href: user_path(user), title: I18n.t('nav.my_account')) }
      end

      context 'when pupil signed in' do
        let(:user) { create(:pupil) }

        it { expect(nav).to have_no_link(href: user_path(user), title: I18n.t('nav.my_account')) }
      end

      context 'when school onboarding user signed in' do
        let(:user) { create(:onboarding_user) }

        it { expect(nav).to have_no_link(href: user_path(user), title: I18n.t('nav.my_account')) }
      end

      context 'when user signed out' do
        let(:user) {}

        it { expect(nav).to have_no_link(title: I18n.t('nav.my_account')) }
      end
    end
  end
end
