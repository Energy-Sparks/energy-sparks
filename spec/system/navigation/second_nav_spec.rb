require 'rails_helper'

RSpec.describe 'Navigation -> second nav', type: :system do
  let(:nav) { page.find(:css, 'nav.navbar-second') }
  let!(:user) {}

  let(:school) { create(:school) }
  let(:school_with_points) { create(:school, :with_points, scoreboard: create(:scoreboard)) }

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
      before { visit contact_path }

      context 'when current user has a school' do
        let(:user) { create(:user, school: school) }

        it 'shows back to dashboard link' do
          expect(nav).to have_link('Back to dashboard', href: school_path(school))
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

        it { expect(nav).not_to have_css('#mini-podium') }
      end
    end

    context 'when on a page with a non-school context' do
      before { visit contact_path }

      it { expect(nav).not_to have_css('#mini-podium') }
    end
  end

  # TODO: add missing translations for mini podium

  # TODO: school status buttons

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

  # TODO:
  # manage school menu
  # school groups schools menu
  # my school menu
  # my schools menu
  # sign out link
  # sign in link
end
