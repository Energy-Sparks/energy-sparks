require 'rails_helper'

RSpec.describe SchoolTarget, type: :model do

  let(:school)          { create(:school) }
  let(:start_date)      { Date.today.beginning_of_month}
  let(:target_date)     { Date.today.beginning_of_month.next_year}

  context "when validating" do
    it "should require target and start dates" do
      target = SchoolTarget.new({school: school, electricity: 10})
      expect(target.valid?).to be false
    end

    it "should require a least one target" do
      target = SchoolTarget.new({school: school, start_date: start_date, target_date: target_date})
      expect(target.valid?).to be false
    end

    it "should allow nil values for some targets" do
      target = SchoolTarget.new({school: school, start_date: start_date, target_date: target_date, electricity: 10})
      expect(target.valid?).to be true

      target = SchoolTarget.new({school: school, start_date: start_date, target_date: target_date, gas: 10})
      expect(target.valid?).to be true

      target = SchoolTarget.new({school: school, start_date: start_date, target_date: target_date, storage_heaters: 10})
      expect(target.valid?).to be true

    end
  end

  context "when finding current target" do
    it "should know if its current" do
      target = SchoolTarget.new({school: school, electricity: 10, start_date: start_date, target_date: target_date})
      expect(target.current?).to be true

      target = SchoolTarget.new({school: school, electricity: 10, start_date: start_date, target_date: Date.today.last_year})
      expect(target.current?).to be false

      target = SchoolTarget.new({school: school, electricity: 10, start_date: Date.tomorrow, target_date: target_date})
      expect(target.current?).to be false
    end
  end

  context "when converting to meter attributes" do
    let(:school)      { create(:school) }
    let(:target)      { create(:school_target, school: school, electricity: 10.0, gas: 5.0, storage_heaters: 7.0) }

    it "should generate aggregated electricity attribute" do
      attribute = MeterAttribute.to_analytics([target.meter_attribute_for_electricity_target])
      expect(attribute[:targeting_and_tracking][0][:start_date]).to eql(target.start_date)
      expect(attribute[:targeting_and_tracking][0][:target]).to eql(0.9)
    end

    it "should generate aggregated gas attribute" do
      attribute = MeterAttribute.to_analytics([target.meter_attribute_for_gas_target])
      expect(attribute[:targeting_and_tracking][0][:start_date]).to eql(target.start_date)
      expect(attribute[:targeting_and_tracking][0][:target]).to eql(0.95)
    end

    it "should generate aggregated storage attribute" do
      attribute = MeterAttribute.to_analytics([target.meter_attribute_for_storage_heaters_target])
      expect(attribute[:targeting_and_tracking][0][:start_date]).to eql(target.start_date)
      expect(attribute[:targeting_and_tracking][0][:target]).to eql(0.93)
    end

    it "should generate all attributes when provided" do
      attributes = target.meter_attributes_by_meter_type
      expect(attributes[:aggregated_electricity]).to_not be_empty
      expect(attributes[:aggregated_gas]).to_not be_empty
      expect(attributes[:storage_heater_aggregated]).to_not be_empty
    end
  end

end
