require 'rails_helper'

RSpec.describe ProgrammeActivity, type: :model do
  let(:activity_type_1)  { create(:activity_type) }
  let(:activity_type_2)  { create(:activity_type) }
  let(:school_1)         { create(:school) }
  let(:activity_1)       { create(:activity, activity_type: activity_type_1, school: school_1) }
  let(:activity_2)       { create(:activity, activity_type: activity_type_2, school: school_1) }
  let(:programme_type_1) { ProgrammeType.create(active: true, title: 'Programme one') }
  let(:programme_1)      { Programme.create(school: school_1, programme_type: programme_type_1, status: "started", started_on: DateTime.now) }

  before do
    programme_type_1.activity_types << activity_type_1
    programme_type_1.save!
  end

  it "validates a new programme activity is created with an activity_type that is also in the programme's programme_type activity_type's" do
    expect(ProgrammeActivity.new(programme: programme_1, activity_type: activity_type_1, activity: activity_1)).to be_valid
    expect(ProgrammeActivity.new(programme: programme_1, activity_type: activity_type_2, activity: activity_2)).not_to be_valid
  end

  it "program activity remains after the activity type has been removed from a programme" do
  end
end
