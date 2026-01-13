require 'rails_helper'

RSpec.describe 'Schools page' do
  let!(:a_school_group) { create(:school_group, name: 'A Group Trust')}
  let!(:b_school_group) { create(:school_group, name: 'B Group Academy')}

  let!(:a_school) { create(:school, active: true, visible: true, name: 'A School Academy', school_group: a_school_group) }
  let!(:b_school) { create(:school, active: true, visible: true, name: 'B School Primary', school_group: b_school_group) }

  shared_examples 'a letter browse view' do
    it 'shows the right page state', :js do
      expect(page).to have_css('li.letter.active', text: 'B')
      expect(page).not_to have_css('li.letter.active', text: 'A')
      expect(page).not_to have_content(I18n.t('components.search_results.keyword.title'))
    end
  end

  shared_examples 'a keyword search view' do
    it 'shows the right page state', :js do
      expect(page).not_to have_css('li.letter.active', text: 'A')
      expect(page).to have_content(I18n.t('components.search_results.keyword.title'))
    end
  end

  shared_examples 'school letter browse results' do
    it_behaves_like 'a letter browse view'

    it 'shows the right results', :js do
      expect(page).to have_content('1 school')
      expect(page).to have_link(b_school.name, href: school_path(b_school))
      expect(page).not_to have_link(a_school.name, href: school_path(a_school))
      expect(page).not_to have_link(a_school_group.name, href: school_group_path(a_school))
      expect(page).not_to have_link(b_school_group.name, href: school_group_path(b_school))
    end
  end

  shared_examples 'school group letter browse results' do
    it_behaves_like 'a letter browse view'

    it 'shows the right results', :js do
      expect(page).to have_content('1 school group')

      expect(page).to have_link(b_school_group.name, href: school_group_path(b_school_group))
      expect(page).not_to have_link(a_school_group.name, href: school_group_path(a_school_group))
      expect(page).not_to have_link(a_school.name, href: school_path(a_school))
      expect(page).not_to have_link(b_school.name, href: school_path(b_school))
    end
  end

  shared_examples 'school keyword search results' do
    it_behaves_like 'a keyword search view'

    it 'shows the right results', :js do
      expect(page).to have_content('1 school')
      expect(page).to have_link(b_school.name, href: school_path(b_school))

      expect(page).not_to have_link(a_school.name, href: school_path(a_school))
      expect(page).not_to have_link(a_school_group.name, href: school_group_path(a_school_group))
      expect(page).not_to have_link(b_school_group.name, href: school_group_path(b_school_group))
    end
  end

  shared_examples 'school group keyword search results' do
    it_behaves_like 'a keyword search view'

    it 'shows the right results', :js do
      expect(page).to have_content('1 school group')
      expect(page).to have_link(b_school_group.name, href: school_group_path(b_school_group))

      expect(page).not_to have_link(a_school_group.name, href: school_group_path(a_school_group))
      expect(page).not_to have_link(a_school.name, href: school_path(a_school))
      expect(page).not_to have_link(b_school.name, href: school_path(b_school))
    end
  end

  context 'when viewing page' do
    before do
      visit schools_path
    end

    it { expect(page).to have_title(I18n.t('schools.index.title')) }
    it { expect(page).to have_content(I18n.t('schools.index.title')) }
    it { expect(page).to have_css('div#geo-json-map') }
    it { expect(page).to have_css('div.school-search-component') }
    it { expect(page).to have_link(I18n.t('schools.index.case_studies'), href: case_studies_path) }
    it { expect(page).to have_content('We have 2 schools') }
    it { expect(page).to have_content(I18n.t('components.school_search.schools.total', count: 2)) }
  end

  context 'with the schools tab' do
    before do
      visit schools_path
    end

    it 'shows correct default tab state' do
      expect(page).to have_css('a.nav-link.active', text: I18n.t('components.school_search.schools.tab'))
      expect(page).to have_css('a.nav-link', text: I18n.t('components.school_search.school_groups.tab'))
    end

    it 'shows letter A schools by default' do
      expect(page).to have_link(a_school.name, href: school_path(a_school))
      expect(page).not_to have_link(b_school.name, href: school_path(b_school))
      expect(page).not_to have_link(a_school_group.name, href: school_group_path(a_school))
      expect(page).not_to have_link(b_school_group.name, href: school_group_path(b_school))
    end

    context 'when there are active, non-visible schools' do
      let!(:invisible_school) do
        create(:school, active: true, visible: false, name: 'An Invisible School', school_group: a_school_group)
      end

      context 'with guest user' do
        before do
          visit schools_path
        end

        it 'only shows visible schools' do
          expect(page).not_to have_link(invisible_school.name, href: school_path(invisible_school))
        end
      end

      context 'with an admin login' do
        before do
          sign_in(create(:admin))
          visit schools_path
        end

        it 'updates label for school count' do
          expect(page).to have_content(I18n.t('components.school_search.schools.total_for_admins', count: 3))
        end

        it 'shows visible schools' do
          expect(page).to have_link(invisible_school.name, href: school_path(invisible_school))
        end
      end
    end

    context 'when browsing by letter' do
      before do
        click_on('B')
      end

      it_behaves_like 'school letter browse results'
    end

    context 'when searching by keyword' do
      before do
        fill_in('schools-keyword', with: 'Primary')
        find('#schools-search-submit').click
      end

      it_behaves_like 'school keyword search results'
    end

    context 'with url parameters for letter' do
      before do
        visit schools_path(letter: 'B', scope: :schools)
      end

      it_behaves_like 'school letter browse results'
    end

    context 'with url parameters for keyword' do
      before do
        visit schools_path(keyword: 'Primary', scope: :schools)
      end

      it_behaves_like 'school keyword search results'
    end
  end

  context 'with the school groups tab', :js do
    before do
      visit schools_path
      click_on I18n.t('components.school_search.school_groups.tab')
    end

    it 'shows letter A school groups by default', :js do
      expect(page).to have_link(a_school_group.name, href: school_group_path(a_school_group))

      expect(page).not_to have_link(b_school_group.name, href: school_group_path(b_school_group))
      expect(page).not_to have_link(a_school.name, href: school_path(a_school))
      expect(page).not_to have_link(b_school.name, href: school_path(b_school))
    end

    context 'when browsing by letter' do
      before do
        within('#school-groups') do
          click_on('B')
        end
      end

      it_behaves_like 'school group letter browse results'
    end

    context 'when searching by keyword' do
      before do
        fill_in('school-groups-keyword', with: 'Academy')
        find('#school-groups-search-submit').click
      end

      it_behaves_like 'school group keyword search results'
    end

    context 'with url parameters for letter' do
      before do
        visit schools_path(letter: 'B', scope: :school_groups)
      end

      it_behaves_like 'school group letter browse results'
    end

    context 'with url parameters for keyword' do
      before do
        visit schools_path(keyword: 'Academy', scope: :school_groups)
      end

      it_behaves_like 'school group keyword search results'
    end
  end
end
