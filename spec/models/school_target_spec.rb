require 'rails_helper'

RSpec.describe SchoolTarget, type: :model do

  let(:school)  { create(:school) }

  it "should require a target date" do
    target = SchoolTarget.new({school: school, electricity: 10})
    expect(target.valid?).to be false
  end

  it "should require a least one target" do
    target = SchoolTarget.new({school: school, target: Date.today.next_year})
    expect(target.valid?).to be false
  end

  it "should know if its current" do
    target = SchoolTarget.new({school: school, electricity: 10, target: Date.today.next_year})
    expect(target.current?).to be true

    target = SchoolTarget.new({school: school, electricity: 10, target: Date.today.last_year})
    expect(target.current?).to be false
  end

  context "as meter attributes" do
    let(:school)      { create(:school) }
    let(:target)      { create(:school_target, school: school, electricity: 10.0, gas: 5.0, storage_heaters: 7.0) }

    it "should generate aggregated electricity attribute" do
      attribute = MeterAttribute.to_analytics([target.meter_attribute_for_electricity_target])
      expect(attribute[:targeting_and_tracking][0][:start_date]).to eql(target.created_at.to_date.beginning_of_month)
      expect(attribute[:targeting_and_tracking][0][:target]).to eql(90.0)
    end

    it "should generate aggregated gas attribute" do
      attribute = MeterAttribute.to_analytics([target.meter_attribute_for_gas_target])
      expect(attribute[:targeting_and_tracking][0][:start_date]).to eql(target.created_at.to_date.beginning_of_month)
      expect(attribute[:targeting_and_tracking][0][:target]).to eql(95.0)
    end

    it "should generate aggregated storage attribute" do
      attribute = MeterAttribute.to_analytics([target.meter_attribute_for_storage_heaters_target])
      expect(attribute[:targeting_and_tracking][0][:start_date]).to eql(target.created_at.to_date.beginning_of_month)
      expect(attribute[:targeting_and_tracking][0][:target]).to eql(93.0)
    end

    it "should generate all attributes when provided" do
      attributes = target.meter_attributes_by_meter_type
      expect(attributes[:aggregated_electricity]).to_not be_empty
      expect(attributes[:aggregated_gas]).to_not be_empty
      expect(attributes[:storage_heater_aggregated]).to_not be_empty
    end
  end

  context "testing school methods" do
    it "should not have a target by default" do
      expect(school.target?).to be false
      expect(school.current_target).to be nil
      expect(school.school_target_attributes).to eql({})
      expect(school.all_pseudo_meter_attributes).to eql({})
    end

    it "should indicate it if has a target" do
      target = create(:school_target, school: school)
      expect(school.target?).to be true
      expect(school.current_target).to eql target
      expect(school.all_pseudo_meter_attributes).to_not eql({})
    end
  end
end
