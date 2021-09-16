require 'rails_helper'

describe Programmes::Creator do

  let(:calendar)        { create(:school_calendar, :with_academic_years, academic_year_count: 2)}
  let(:school)          { create(:school, calendar: calendar ) }
  let(:programme_type)  { create(:programme_type_with_activity_types) }

  let(:service) { Programmes::Creator.new(school, programme_type) }

  describe "#create" do
    let(:programme) { school.programmes.first }

    context 'when school has no activities' do
      before(:each) do
        service.create
      end

      it "creates school programme" do
        expect(school.programmes.count).to eql 1
        expect(programme.programme_type).to eql programme_type
      end

      it "starts programme today" do
        expect(programme.started_on).to eql Date.today
      end

      it "marks programme as started" do
        expect(programme.started?).to be true
      end

      it "doesnt create any programme activities by default" do
        expect(programme.programme_activities.any?).to be false
      end

      it "does not have an activity" do
        expect(school.programmes.first.activities.any?).to be false
      end

      it "doesnt enrol twice" do
        service.create
        expect(school.programmes.count).to eql 1
      end

    end

    context "when school has recent activity in programme" do
      let!(:activity) { create(:activity, school: school, activity_type: programme_type.activity_types.first)}
      before(:each) do
        service.create
      end
      it "recognises progress when recent" do
        expect(programme.programme_activities.count).to be 1
        expect(programme.activities.any?).to be true
        expect(programme.activities.first).to eq activity
      end

    end

    context "when school has multiple activities" do
      let!(:activity) { create(:activity, school: school, activity_type: programme_type.activity_types.first)}
      let!(:recent) { create(:activity, school: school, activity_type: programme_type.activity_types.first, happened_on: Date.yesterday)}
      let!(:old_activity) { create(:activity, school: school, activity_type: programme_type.activity_types.first, happened_on: Date.today.last_year)}

      before(:each) do
        service.create
      end

      it "recognises the most recent" do
        expect(programme.programme_activities.count).to be 1
        expect(programme.activities.any?).to be true
        expect(programme.activities.first).to eq activity
      end

    end
    context "when school recorded an activity last year" do
      let!(:activity) { create(:activity, school: school, activity_type: programme_type.activity_types.first, happened_on: Date.today.last_year)}
      before(:each) do
        service.create
      end
      it "this doesnt count towards progress" do
        expect(programme.programme_activities.count).to be 0
        expect(programme.activities.any?).to be false
      end
    end

  end
end
