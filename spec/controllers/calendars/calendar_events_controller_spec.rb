require 'rails_helper'

RSpec.describe Calendars::CalendarEventsController, type: :controller do
  include_context 'calendar data'

  let!(:school)           { create_active_school }
  let!(:school_admin)     { create(:school_admin, school: school) }

  let!(:school_calendar) do
    cal = CalendarFactory.new(existing_calendar: calendar, title: 'New calendar', calendar_type: :school).create
    cal.schools << school
    cal
  end

  let!(:valid_attributes) do
    {
      calendar_event_type_id: CalendarEventType.first.id,
      start_date: "2022-01-01",
      end_date: "2022-01-31"
    }
  end

  # academic years are automatically created with factory instances, but not "real" ones, so we need to create..
  let!(:academic_years) { AcademicYearFactory.new(parent_template_calendar).create(start_year: 2021, end_year: 2023) }

  before do
    sign_in_user(:admin)
  end

  describe "POST #create" do
    it 'creates event' do
      post :create, params: { calendar_id: calendar.id, calendar_event: valid_attributes }
      event = CalendarEvent.where(calendar: calendar, start_date: Date.parse("2022-01-01")).last
      expect(response).to redirect_to(calendar_path(calendar, anchor: "calendar_event_#{event.id}"))
    end

    it 'broadcasts calendar changed' do
      expect do
        post :create, params: { calendar_id: calendar.id, calendar_event: valid_attributes }
      end.to broadcast(:calendar_edited, calendar)
    end
  end

  describe "PUT #update" do
    let!(:new_attributes) do
      {
        start_date: "2022-01-02",
        end_date: "2022-01-31"
      }
    end
    let!(:event) { CalendarEvent.first }

    it 'updates event' do
      put :update, params: { calendar_id: event.calendar.id, id: event.to_param, calendar_event: new_attributes }
      event.reload
      expect(event.start_date.iso8601).to eql(new_attributes[:start_date])
    end

    it 'broadcasts calendar changed' do
      expect do
        put :update, params: { calendar_id: event.calendar.id, id: event.to_param, calendar_event: new_attributes }
      end.to broadcast(:calendar_edited, event.calendar)
    end
  end

  describe "DELETE #destroy" do
    let!(:event) { CalendarEvent.first }

    it 'removes event' do
      expect do
        delete :destroy, params: { calendar_id: event.calendar.id, id: event.to_param }
      end.to change(CalendarEvent, :count).by(-1)
    end

    it 'broadcasts event' do
      expect do
        delete :destroy, params: { calendar_id: event.calendar.id, id: event.to_param }
      end.to broadcast(:calendar_edited, event.calendar)
    end
  end
end
