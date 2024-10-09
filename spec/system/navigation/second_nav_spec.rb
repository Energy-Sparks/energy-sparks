# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Navigation -> second nav' do
  let!(:user) {}
  let(:school_group) { create(:school_group) }
  let(:school) { create(:school, school_group:) }
  let(:school_with_points) { create(:school, :with_points, scoreboard: create(:scoreboard)) }
  let(:nav) { page.find(:css, 'nav.navbar-second') }

  before do
    Flipper.enable :navigation
    sign_in(user) if user
  end

  describe 'Dashboard link' do
    context 'when on a page with school context' do
      before { visit school_path(school) }

      it 'shows school name and dashboard link' do
        expect(nav).to have_link(school.name, href: school_path(school))
      end
    end

    context 'when on a page in a non school context' do
      before { visit home_page_path }

      context 'when current user has a school' do
        let(:user) { create(:user, school:) }

        it 'shows back to dashboard link' do
          expect(nav).to have_link('Back to dashboard', href: school_path(school))
        end
      end

      context 'when current user does not have a school' do
        let(:user) { create(:user, school: nil) }

        it 'shows back to dashboard link' do
          expect(nav).to have_no_link('Back to dashboard')
        end
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

  # TODO: add missing translations for mini podium

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

  describe 'Manage group menu' do
    let(:manage_school_group_menu) { nav.find_by(id: 'manage-school-group-menu') }

    context 'when on a non school group page' do
      before { visit home_page_path }

      it { expect(nav).to have_no_css('#manage-school-group-menu') }
    end

    context 'when on school group page' do
      before { visit school_group_path(school.school_group) }

      context 'when user is a school group admin for different school' do
        let(:user) { create(:group_admin, school_group: create(:school_group)) }

        it { expect(nav).to have_no_css('#manage-school-group-menu') }
      end

      context 'when user is a school group admin for that school' do
        let(:user) { create(:group_admin, school_group:) }

        it { expect(nav).to have_css('#manage-school-group-menu') }
      end

      context 'when user is not a school group admin' do
        it { expect(nav).to have_no_css('#manage-school-group-menu') }
      end
    end

    ## TODO: check menu contents, but this is currently fluid, so should be done later
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

    ## TODO: check menu contents (too fluid at the mo, so worth doing later)
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

      ## TODO: check menu contents (too fluid at the mo, so worth doing later)
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
end
