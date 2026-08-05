# frozen_string_literal: true

require 'rails_helper'

describe 'activity types' do
  describe 'search' do
    let!(:activity_types) do
      [create(:activity_type, name: 'foo', description: 'activity'),
       create(:activity_type, name: 'bar', description: 'second activity')]
    end

    context 'when visiting search page' do
      before do
        visit activity_categories_path
        click_on 'Search'
      end

      it 'shows empty page' do
        expect(page).to have_text('Find pupil activities')
        expect(page).to have_no_text('No results found')
      end
    end

    it 'links to activity categories page' do
      visit search_activity_types_path
      click_on 'All activities'

      expect(page).to have_text('Explore energy saving activities')
    end

    it 'links to interventions page' do
      visit search_activity_types_path
      click_on 'Adult actions'

      expect(page).to have_text('Explore energy saving actions')
    end

    it 'shows search results' do
      visit search_activity_types_path
      fill_in 'query', with: 'foo'
      click_on 'Search'

      expect(page).to have_text(activity_types[0].name)
    end

    it 'shows no results' do
      visit search_activity_types_path
      fill_in 'query', with: 'blah'
      click_on 'Search'

      expect(page).to have_text('No results found')
    end

    context 'when paginating' do
      around do |ex|
        run_with_temporary_pagy_default(limit: 1) do
          visit search_activity_types_path
          ex.run
        end
      end

      it 'limits the search results' do
        fill_in 'query', with: 'activity'
        click_on 'Search'

        # possibly flickering as ordering might be different?
        # test could instead assert whether there is expect number of
        # result rows, check for navigation, etc.
        expect(page).to have_text(activity_types[0].name)
        expect(page).to have_no_text(activity_types[1].name)

        click_on '>'
        expect(page).to have_no_text(activity_types[0].name)
        expect(page).to have_text(activity_types[1].name)
      end
    end

    context 'when filtering' do
      let(:key_stages) { [create(:key_stage, name: 'KS1'), create(:key_stage, name: 'KS2')] }
      let(:subjects) do
        [create(:subject, name: 'Citizenship'),
         create(:subject, name: 'Languages, Literacy and Communication')]
      end
      let!(:activity_types) do
        [create(:activity_type, name: 'baz one', key_stages: [key_stages[0]], subjects: [subjects[0]]),
         create(:activity_type, name: 'baz two', key_stages: [key_stages[1]], subjects: [subjects[1]])]
      end

      context 'when visiting the search page' do
        before do
          visit search_activity_types_path
        end

        it 'finds all with no filter' do
          fill_in 'query', with: 'baz'
          click_on 'Search'
          # flickering?
          expect(page).to have_text('baz one')
          expect(page).to have_text('baz two')
        end

        it 'shows result count' do
          fill_in 'query', with: 'baz'
          click_on 'Search'
          expect(page).to have_text('2 results found')
        end

        it 'finds result with key stage filter' do
          fill_in 'query', with: 'baz'
          click_on 'Search'
          click_on key_stages[0].name
          expect(page).to have_text('baz one')
          expect(page).to have_no_text('baz two')
        end

        it 'keeps filters for next search' do
          fill_in 'query', with: 'baz'
          click_on 'Search'
          click_on key_stages[0].name
          expect(page).to have_text('baz one')
          expect(page).to have_no_text('baz two')
          fill_in 'query', with: 'baz'
          click_on 'Search'
          expect(page).to have_text('baz one')
          expect(page).to have_no_text('baz two')
        end

        it 'shows filtered result count' do
          fill_in 'query', with: 'baz'
          click_on 'Search'
          click_on key_stages[0].name
          expect(page).to have_text('1 result found')
        end

        it 'finds result with subject 1 filter' do
          fill_in 'query', with: 'baz'
          click_on 'Search'
          click_on subjects[0].name
          expect(page).to have_text('baz one')
          expect(page).to have_no_text('baz two')
        end

        it 'finds result with subject 2 filter' do
          fill_in 'query', with: 'baz'
          click_on 'Search'
          click_on subjects[1].name
          expect(page).to have_no_text('baz one')
          expect(page).to have_text('baz two')
        end

        it 'finds none if key stage and subject filtered' do
          fill_in 'query', with: 'baz'
          click_on 'Search'
          click_on key_stages[0].name
          click_on subjects[1].name
          expect(page).to have_text('No results found')
        end

        it 'toggles selected filter highlight' do
          expect(page).to have_css('a.text-bg-light', text: subjects[1].name)
          click_on subjects[1].name
          expect(page).to have_css('a.text-bg-dark', text: subjects[1].name)
          click_on subjects[1].name
          expect(page).to have_css('a.text-bg-light', text: subjects[1].name)
        end
      end
    end
  end
end
