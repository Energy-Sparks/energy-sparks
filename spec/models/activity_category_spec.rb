require 'rails_helper'

describe 'ActivityCategory' do

  subject { create :activity_category }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  it 'should sort its types correctly' do
    subject.activity_types << FactoryGirl.create(:activity_type, name: "A")

    expect( subject.sorted_activity_types.length ).to eql(1)

    subject.activity_types << FactoryGirl.create(:activity_type, name: "other")
    subject.activity_types << FactoryGirl.create(:activity_type, name: "Z")

    expect( subject.sorted_activity_types.length ).to eql(3)
    expect( subject.sorted_activity_types.last.name ).to eql("other")

  end
end