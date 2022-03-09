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

  let!(:valid_attributes) {
    {
      calendar_event_type_id: CalendarEventType.first.id,
      title: "My New Event",
      start_date: "2022-01-01",
      end_date: "2022-01-31"
    }
  }

  before(:each) do
    sign_in_user(:admin)
  end

  describe "POST #create" do
    it 'creates event' do
      post :create, params: { calendar_id: calendar.id, calendar_event: valid_attributes }
      expect(response).to redirect_to(calendar_path(calendar))
    end
    it 'broadcasts calendar changed' do
      expect_any_instance_of(CalendarEventListener).to receive(:calendar_edited).with(calendar)
      post :create, params: { calendar_id: calendar.id, calendar_event: valid_attributes }
    end
  end

  describe "PUT #update" do
    let!(:new_attributes) {
      {
        title: "My Updated Event",
        start_date: "2022-01-01",
        end_date: "2022-01-31"
      }
    }
    let!(:event)  { CalendarEvent.first }
    it 'updates event' do
      put :update, params: {calendar_id: event.calendar.id, id: event.to_param, calendar_event: new_attributes}
      event.reload
      expect(event.title).to eql(new_attributes[:title])
    end

    it 'broadcasts calendar changed' do
      expect_any_instance_of(CalendarEventListener).to receive(:calendar_edited).with(event.calendar)
      put :update, params: {calendar_id: event.calendar.id, id: event.to_param, calendar_event: new_attributes}
      event.reload
      expect(event.title).to eql(new_attributes[:title])
    end
  end

  describe "DELETE #destroy" do
    let!(:event)  { CalendarEvent.first }
    it 'removes event' do
      expect {
        delete :destroy, params: { calendar_id: event.calendar.id, id: event.to_param }
      }.to change(CalendarEvent, :count).by(-1)
    end

    it 'broadcasts event' do
      expect_any_instance_of(CalendarEventListener).to receive(:calendar_edited).with(event.calendar)
      expect {
        delete :destroy, params: { calendar_id: event.calendar.id, id: event.to_param }
      }.to change(CalendarEvent, :count).by(-1)
    end
  end
end
