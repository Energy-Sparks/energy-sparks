# frozen_string_literal: true

require 'rails_helper'

describe 'calendar view' do
  context 'when an admin' do
    before { sign_in(create(:admin)) }

    context 'with the current events tab' do
      include_context 'calendar data'

      before do
        visit current_events_calendar_path(calendar)
        create(:academic_year, calendar: calendar, start_date: Date.parse("01/01/#{Time.zone.today.year}"))
      end

      it 'current events are rendered with just the events data table' do
        expect(page).to have_text('Type')
        expect(page).to have_text('Start Date')
        expect(page).to have_text('End Date')
        expect(page).to have_no_text(calendar.title)
      end
    end

    describe 'using the calendar view', :js do
      let(:term_start_date) { Date.new(Date.current.year) }
      let(:inset_day_type) { create(:calendar_event_type, :inset_day_in_school) }

      before do
        calendar
        # need to do this after calendar so ID is greater in JSON generated as it shows those with higher
        # IDs when multiple are present
        inset_day_type
        visit calendar_path(calendar)
      end

      shared_examples_for 'it adds an event' do
        let(:date) { Date.new(Date.current.year, 1, 15) }

        def click_day
          first('.calendar .day', text: date.day, wait: 10).click # flaking so added extra wait
        end

        def wait_for_modal
          expect(page).to have_css('#event-modal', visible: :hidden)
        end

        def new_calendar_event
          calendar.calendar_events.where(start_date: date).first
        end

        def create_event
          click_day
          expect(page).to have_text('New Calendar Event')
          select('In school Inset Day - Training day in school', from: 'calendar_event_calendar_event_type_id')
          click_on('Save Changes')
          wait_for_modal
          with_retry do
            expect(new_calendar_event).to \
              have_attributes(based_on_id: nil, end_date: date, calendar_event_type: inset_day_type)
          end
        end

        def delete_event
          click_day
          expect(page).to have_text('Edit Calendar Event')
          click_on('Delete')
          wait_for_modal
          with_retry { expect(new_calendar_event).to be_nil }
        end

        it 'shows the calendar, allows an event to be added and deleted' do
          click_on('Calendar view')
          expect(page).to have_text(calendar.title)
          expect(page).to have_text('January')
          create_event
          delete_event
        end
      end

      context 'with a single calendar' do
        let(:calendar) { create(:calendar, :with_terms_and_holidays, term_start_date:) }

        it_behaves_like 'it adds an event'
      end

      context 'with an inherited calendar' do
        let(:calendar) do
          calendar = create(:calendar, based_on: create(:calendar, :with_terms_and_holidays, term_start_date:))
          CalendarResetService.new(calendar).reset
          calendar
        end

        it_behaves_like 'it adds an event'
      end
    end
  end

  describe 'a school admin can' do
    include_context 'calendar data'

    let!(:school)           { create_active_school }
    let!(:school_admin)     { create(:school_admin, school: school) }
    let!(:school_calendar) do
      cal = CalendarFactory.new(existing_calendar: calendar, title: 'New calendar', calendar_type: :school).create
      cal.schools << school
      cal
    end

    it 'add an event to their calendar' do
      calendar_event_count = CalendarEvent.count

      sign_in(school_admin)
      visit school_path(school)

      click_on('School calendar')
      click_on('Add new event', match: :first)
      first('input#calendar_event_start_date', visible: false).set('16/08/2018')
      first('input#calendar_event_end_date', visible: false).set('17/08/2018')

      click_on 'Create Calendar event'
      expect(CalendarEvent.count).to eq calendar_event_count + 1
    end

    it "but not to someone else's calendar" do
      sign_in(school_admin)
      visit calendar_path(calendar)

      expect(page).to have_text('You are not authorized')
    end
  end
end
